import {onRequest} from "firebase-functions/v2/https";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {setGlobalOptions} from "firebase-functions/v2/options";
import {initializeApp} from "firebase-admin/app";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import axios from "axios";
import cors from "cors";
import {Request, Response} from "express";
import * as cheerio from "cheerio";

initializeApp();
const db = getFirestore();

setGlobalOptions({
  region: "asia-northeast1",
  timeoutSeconds: 60,
  memory: "256MiB",
});

const corsHandler = cors({origin: true});

interface TrendingRepo {
  id: string;
  name: string;
  fullName: string;
  owner: string;
  description: string;
  stars: number;
  starsToday: number;
  forks: number;
  language: string | null;
  languageColor: string | null;
  url: string;
  descriptionJa?: string;
  summaryJa?: string;
}

interface CachedSummary {
  fullName: string;
  description: string;
  descriptionJa: string;
  summaryJa: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

function parseStarsText(text: string): number {
  const cleanText = text.replace(/,/g, "").trim();
  const match = cleanText.match(/(\d+)/);
  return match ? parseInt(match[1], 10) : 0;
}

async function scrapeGitHubTrending(
  since: string,
  language: string
): Promise<TrendingRepo[]> {
  let url = "https://github.com/trending";

  if (language) {
    url += `/${encodeURIComponent(language)}`;
  }
  url += `?since=${since}`;

  const response = await axios.get(url, {
    timeout: 30000,
    headers: {
      "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 " +
        "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
      "Accept": "text/html,application/xhtml+xml",
      "Accept-Language": "en-US,en;q=0.9",
    },
  });

  const $ = cheerio.load(response.data);
  const repos: TrendingRepo[] = [];

  $("article.Box-row").each((_idx, article) => {
    try {
      const $article = $(article);

      const repoLink = $article.find("h2.h3 a").attr("href")?.trim() || "";
      const fullName = repoLink.replace(/^\//, "");
      const [owner, name] = fullName.split("/");

      if (!owner || !name) return;

      const description =
        $article.find("p.col-9").text().trim() || "";

      const langSpan = $article.find('span[itemprop="programmingLanguage"]');
      const language = langSpan.text().trim() || null;

      const langColorSpan = $article.find(".repo-language-color");
      const bgColor = langColorSpan.css("background-color") ||
        langColorSpan.attr("style")?.match(/background-color:\s*([^;]+)/)?.[1] ||
        null;

      let totalStars = 0;
      let forks = 0;
      $article.find("a.Link--muted").each((_i, linkEl) => {
        const href = $(linkEl).attr("href") || "";
        const text = $(linkEl).text().trim();

        if (href.includes("/stargazers")) {
          totalStars = parseStarsText(text);
        } else if (href.includes("/forks")) {
          forks = parseStarsText(text);
        }
      });

      let starsToday = 0;
      const starsSpan = $article.find("span.d-inline-block.float-sm-right");
      if (starsSpan.length) {
        starsToday = parseStarsText(starsSpan.text());
      }

      repos.push({
        id: fullName,
        name,
        fullName,
        owner,
        description,
        stars: totalStars,
        starsToday,
        forks,
        language,
        languageColor: bgColor,
        url: `https://github.com/${fullName}`,
      });
    } catch (e) {
      console.error("Error parsing repo:", e);
    }
  });

  return repos;
}

async function getCachedSummary(fullName: string): Promise<CachedSummary | null> {
  const docId = fullName.replace("/", "_");
  const docRef = db.collection("repo_summaries").doc(docId);
  const doc = await docRef.get();
  
  if (doc.exists) {
    return doc.data() as CachedSummary;
  }
  return null;
}

async function saveSummaryToCache(
  fullName: string,
  description: string,
  descriptionJa: string,
  summaryJa: string
): Promise<void> {
  const docId = fullName.replace("/", "_");
  const docRef = db.collection("repo_summaries").doc(docId);
  
  const existing = await docRef.get();
  const now = Timestamp.now();
  
  if (existing.exists) {
    await docRef.update({
      description,
      descriptionJa,
      summaryJa,
      updatedAt: now,
    });
  } else {
    await docRef.set({
      fullName,
      description,
      descriptionJa,
      summaryJa,
      createdAt: now,
      updatedAt: now,
    });
  }
}

async function fetchReadme(fullName: string): Promise<string | null> {
  const apiUrl = `https://api.github.com/repos/${fullName}/readme`;
  try {
    const response = await axios.get(apiUrl, {
      timeout: 10000,
      headers: {
        "Accept": "application/vnd.github.v3.raw",
        "User-Agent": "GitTrend-JP/1.0",
      },
    });
    if (response.status === 200) {
      let text = response.data as string;
      text = text.replace(/```[\s\S]*?```/g, "");
      text = text.replace(/`[^`]+`/g, "");
      text = text.replace(/#+\s/g, "");
      text = text.replace(/\[([^\]]+)\]\([^)]+\)/g, "$1");
      text = text.replace(/<[^>]+>/g, "");
      text = text.replace(/!\[[^\]]*\]\([^)]+\)/g, "");
      text = text.replace(/\n{3,}/g, "\n\n");
      text = text.trim();
      if (text.length > 3000) {
        text = text.substring(0, 3000) + "...";
      }
      return text;
    }
    return null;
  } catch (e) {
    console.error(`Error fetching README for ${fullName}:`, e);
    return null;
  }
}

async function summarizeWithGemini(
  text: string,
  repoName: string,
  description: string
): Promise<{summaryJa: string; descriptionJa: string}> {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    console.warn("GEMINI_API_KEY not set");
    return {summaryJa: "", descriptionJa: description};
  }

  const prompt = `あなたはGitHubリポジトリの説明を日本語で要約する専門家です。
以下のリポジトリ情報を日本語で要約してください。

【リポジトリ名】${repoName}
【説明文】${description}
【README内容】
${text.substring(0, 2000)}

【出力形式】JSONで以下の形式で出力してください：
{
  "descriptionJa": "説明文の日本語訳（1-2文、50文字程度）",
  "summaryJa": "READMEの要約（3-5文、150文字程度）。このツールが何をするもので、どんな特徴があるかを簡潔に説明"
}

JSONのみを出力し、他の説明は不要です。`;

  try {
    const response = await axios.post(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=${apiKey}`,
      {
        contents: [{parts: [{text: prompt}]}],
        generationConfig: {
          temperature: 0.3,
          maxOutputTokens: 500,
        },
      },
      {timeout: 30000, headers: {"Content-Type": "application/json"}}
    );

    const content = response.data?.candidates?.[0]?.content?.parts?.[0]?.text;
    if (content) {
      const jsonMatch = content.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        const parsed = JSON.parse(jsonMatch[0]);
        return {
          summaryJa: parsed.summaryJa || "",
          descriptionJa: parsed.descriptionJa || description,
        };
      }
    }
    return {summaryJa: "", descriptionJa: description};
  } catch (e) {
    console.error("Gemini API error:", e);
    return {summaryJa: "", descriptionJa: description};
  }
}

async function getOrCreateSummary(
  fullName: string,
  description: string
): Promise<{descriptionJa: string; summaryJa: string}> {
  const cached = await getCachedSummary(fullName);
  if (cached && cached.summaryJa) {
    return {
      descriptionJa: cached.descriptionJa,
      summaryJa: cached.summaryJa,
    };
  }

  const readme = await fetchReadme(fullName);
  const {summaryJa, descriptionJa} = await summarizeWithGemini(
    readme || description,
    fullName,
    description
  );

  if (summaryJa || descriptionJa !== description) {
    await saveSummaryToCache(fullName, description, descriptionJa, summaryJa);
  }

  return {descriptionJa, summaryJa};
}

async function updateTrendingCacheForPeriod(since: string): Promise<number> {
  console.log(`Updating trending cache for: ${since}`);
  
  const repos = await scrapeGitHubTrending(since, "");
  
  const reposWithSummary: TrendingRepo[] = [];
  for (const repo of repos) {
    try {
      const {descriptionJa, summaryJa} = await getOrCreateSummary(
        repo.fullName,
        repo.description
      );
      reposWithSummary.push({...repo, descriptionJa, summaryJa});
    } catch (e) {
      console.error(`Error getting summary for ${repo.fullName}:`, e);
      reposWithSummary.push(repo);
    }
  }

  const cacheRef = db.collection("trending_cache").doc(since);
  await cacheRef.set({
    since,
    repos: reposWithSummary,
    updatedAt: Timestamp.now(),
    count: reposWithSummary.length,
  });

  console.log(`Updated ${since} cache with ${reposWithSummary.length} repos`);
  return reposWithSummary.length;
}

export const updateTrendingCache = onRequest({
  timeoutSeconds: 540,
  memory: "1GiB",
}, (req: Request, res: Response) => {
  corsHandler(req, res, async () => {
    try {
      const results: Record<string, number> = {};
      
      for (const since of ["daily", "weekly", "monthly"]) {
        results[since] = await updateTrendingCacheForPeriod(since);
      }

      res.json({
        success: true,
        message: "Trending cache updated",
        results,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      console.error("Error updating trending cache:", error);
      res.status(500).json({
        success: false,
        error: "Failed to update trending cache",
      });
    }
  });
});

export const scheduledUpdateTrendingCache = onSchedule({
  schedule: "0 * * * *",
  timeZone: "Asia/Tokyo",
  timeoutSeconds: 540,
  memory: "1GiB",
}, async () => {
  console.log("Starting scheduled trending cache update");
  
  for (const since of ["daily", "weekly", "monthly"]) {
    await updateTrendingCacheForPeriod(since);
  }
  
  console.log("Scheduled trending cache update completed");
});

export const getTrending = onRequest((req: Request, res: Response) => {
  corsHandler(req, res, async () => {
    try {
      const since = (req.query.since as string) || "daily";
      const limit = parseInt(req.query.limit as string) || 25;

      const cacheRef = db.collection("trending_cache").doc(since);
      const cacheDoc = await cacheRef.get();

      if (cacheDoc.exists) {
        const cacheData = cacheDoc.data();
        const repos = (cacheData?.repos || []).slice(0, limit);
        
        res.json({
          success: true,
          data: repos,
          meta: {
            since,
            count: repos.length,
            cached: true,
            cachedAt: cacheData?.updatedAt?.toDate?.()?.toISOString() || null,
            timestamp: new Date().toISOString(),
          },
        });
        return;
      }

      const repos = await scrapeGitHubTrending(since, "");
      const limitedRepos = repos.slice(0, limit);

      res.json({
        success: true,
        data: limitedRepos,
        meta: {
          since,
          count: limitedRepos.length,
          cached: false,
          timestamp: new Date().toISOString(),
        },
      });
    } catch (error) {
      console.error("Error fetching trending:", error);
      res.status(500).json({
        success: false,
        error: "Failed to fetch trending repositories",
      });
    }
  });
});

export const healthCheck = onRequest((req: Request, res: Response) => {
  corsHandler(req, res, () => {
    res.json({
      status: "ok",
      timestamp: new Date().toISOString(),
      version: "2.0.0",
    });
  });
});

interface BookmarkData {
  repositoryId: string;
  fullName: string;
  name: string;
  description: string;
  descriptionJa?: string;
  summaryJa?: string;
  stars: number;
  language: string | null;
  url: string;
  savedAt: Timestamp;
}

export const addBookmark = onRequest((req: Request, res: Response) => {
  corsHandler(req, res, async () => {
    try {
      const userId = req.query.userId as string;
      const repoData = req.body as Partial<BookmarkData>;

      if (!userId || !repoData.repositoryId) {
        res.status(400).json({
          success: false,
          error: "userId and repositoryId are required",
        });
        return;
      }

      const bookmarkRef = db
        .collection("users")
        .doc(userId)
        .collection("bookmarks")
        .doc(repoData.repositoryId.replace("/", "_"));

      await bookmarkRef.set({
        ...repoData,
        savedAt: Timestamp.now(),
      });

      res.json({
        success: true,
        message: "Bookmark added",
      });
    } catch (error) {
      console.error("Error adding bookmark:", error);
      res.status(500).json({
        success: false,
        error: "Failed to add bookmark",
      });
    }
  });
});

export const removeBookmark = onRequest((req: Request, res: Response) => {
  corsHandler(req, res, async () => {
    try {
      const userId = req.query.userId as string;
      const repositoryId = req.query.repositoryId as string;

      if (!userId || !repositoryId) {
        res.status(400).json({
          success: false,
          error: "userId and repositoryId are required",
        });
        return;
      }

      const bookmarkRef = db
        .collection("users")
        .doc(userId)
        .collection("bookmarks")
        .doc(repositoryId.replace("/", "_"));

      await bookmarkRef.delete();

      res.json({
        success: true,
        message: "Bookmark removed",
      });
    } catch (error) {
      console.error("Error removing bookmark:", error);
      res.status(500).json({
        success: false,
        error: "Failed to remove bookmark",
      });
    }
  });
});

export const getBookmarks = onRequest((req: Request, res: Response) => {
  corsHandler(req, res, async () => {
    try {
      const userId = req.query.userId as string;

      if (!userId) {
        res.status(400).json({
          success: false,
          error: "userId is required",
        });
        return;
      }

      const bookmarksRef = db
        .collection("users")
        .doc(userId)
        .collection("bookmarks");

      const snapshot = await bookmarksRef.orderBy("savedAt", "desc").get();
      const bookmarks = snapshot.docs.map((doc) => ({
        ...doc.data(),
        savedAt: doc.data().savedAt?.toDate?.()?.toISOString() || null,
      }));

      res.json({
        success: true,
        data: bookmarks,
        count: bookmarks.length,
      });
    } catch (error) {
      console.error("Error getting bookmarks:", error);
      res.status(500).json({
        success: false,
        error: "Failed to get bookmarks",
      });
    }
  });
});

export const getRepoSummary = onRequest((req: Request, res: Response) => {
  corsHandler(req, res, async () => {
    try {
      const fullName = req.query.repo as string;
      if (!fullName || !fullName.includes("/")) {
        res.status(400).json({
          success: false,
          error: "Invalid repo parameter. Use format: owner/repo",
        });
        return;
      }

      const description = (req.query.description as string) || "";
      
      const cached = await getCachedSummary(fullName);
      if (cached && cached.summaryJa) {
        res.json({
          success: true,
          data: {
            fullName,
            description,
            descriptionJa: cached.descriptionJa,
            readmeSummary: "",
            readmeSummaryJa: cached.summaryJa,
            cached: true,
          },
        });
        return;
      }

      const readme = await fetchReadme(fullName);
      const {summaryJa, descriptionJa} = await summarizeWithGemini(
        readme || description,
        fullName,
        description
      );

      if (summaryJa || descriptionJa !== description) {
        await saveSummaryToCache(fullName, description, descriptionJa, summaryJa);
      }

      res.json({
        success: true,
        data: {
          fullName,
          description,
          descriptionJa,
          readmeSummary: readme?.substring(0, 500) || "",
          readmeSummaryJa: summaryJa,
          cached: false,
        },
      });
    } catch (error) {
      console.error("Error getting repo summary:", error);
      res.status(500).json({
        success: false,
        error: "Failed to get repository summary",
      });
    }
  });
});
