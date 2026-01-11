import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/datasources/github_api.dart';
import '../../../data/models/repository.dart';
import '../../../data/providers/providers.dart';
import '../../widgets/repository_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<Repository> _filterRepositories(List<Repository> repos) {
    if (_searchQuery.isEmpty) return repos;
    return repos.where((repo) {
      return repo.fullName.toLowerCase().contains(_searchQuery) ||
          repo.description.toLowerCase().contains(_searchQuery) ||
          (repo.language?.toLowerCase().contains(_searchQuery) ?? false) ||
          (repo.descriptionJa?.toLowerCase().contains(_searchQuery) ?? false) ||
          (repo.summaryJa?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.l10n;
    final asyncRepos = ref.watch(trendingRepositoriesProvider(TrendingSince.daily));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.search),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: l10n.searchRepositoriesHint,
                hintStyle: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: AppTypography.body,
            ),
          ),
          Expanded(
            child: asyncRepos.when(
              data: (repos) {
                final filteredRepos = _filterRepositories(repos);
                if (filteredRepos.isEmpty) {
                  return _buildEmptyState(l10n);
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: filteredRepos.length,
                  itemBuilder: (context, index) {
                    final repo = filteredRepos[index];
                    return RepositoryCard(
                      fullName: repo.fullName,
                      description: repo.description,
                      stars: repo.stars,
                      starsToday: repo.starsToday,
                      language: repo.language,
                      tags: [],
                      onSaveToggle: () => ref.read(bookmarksProvider.notifier).toggleBookmark(repo),
                      descriptionJa: repo.descriptionJa,
                      summaryJa: repo.summaryJa,
                      url: repo.url,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.failedToLoadRepositories,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(trendingRepositoriesProvider(TrendingSince.daily));
                      },
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    final hasSearchQuery = _searchQuery.isNotEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearchQuery ? Icons.search_off : Icons.search,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            hasSearchQuery ? l10n.noRepositoriesFound : l10n.searchForRepositories,
            style: AppTypography.subtitle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearchQuery
                ? l10n.tryDifferentSearchTerm
                : l10n.enterKeywordToSearch,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
