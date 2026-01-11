import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/errors/api_exception.dart';
import '../../../data/datasources/github_api.dart';
import '../../../data/models/repository.dart';
import '../../../data/providers/providers.dart';
import '../../widgets/repository_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(hours: 1), (_) {
      _refreshAllData();
    });
  }

  void _refreshAllData() {
    ref.invalidate(trendingRepositoriesProvider(TrendingSince.daily));
    ref.invalidate(trendingRepositoriesProvider(TrendingSince.weekly));
    ref.invalidate(trendingRepositoriesProvider(TrendingSince.monthly));
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.l10n;

    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
          child: Text(
            l10n.appTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAllData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          labelStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: l10n.today),
            Tab(text: l10n.weekly),
            Tab(text: l10n.monthly),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TrendingList(since: TrendingSince.daily, titleKey: 'todaysTrending'),
          _TrendingList(since: TrendingSince.weekly, titleKey: 'thisWeek'),
          _TrendingList(since: TrendingSince.monthly, titleKey: 'thisMonth'),
        ],
      ),
    );
  }
}

class _TrendingList extends ConsumerWidget {
  final TrendingSince since;
  final String titleKey;

  const _TrendingList({required this.since, required this.titleKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRepos = ref.watch(trendingRepositoriesProvider(since));
    final l10n = ref.l10n;
    final title = titleKey == 'todaysTrending' 
        ? l10n.todaysTrending 
        : titleKey == 'thisWeek' 
            ? l10n.thisWeek 
            : l10n.thisMonth;

    return asyncRepos.when(
      data: (repos) => _buildList(context, ref, repos, title, l10n),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, stack) => _buildErrorView(context, ref, e, l10n),
    );
  }

  Widget _buildErrorView(BuildContext context, WidgetRef ref, Object error, AppLocalizations l10n) {
    String message;
    IconData icon;
    
    if (error is ApiConnectionException) {
      message = error.message;
      icon = Icons.wifi_off;
    } else if (error is ApiNotFoundException) {
      message = error.message;
      icon = Icons.error_outline;
    } else if (error is ApiServerException) {
      message = error.message;
      icon = Icons.cloud_off;
    } else if (error is ApiException) {
      message = error.message;
      icon = Icons.warning_amber;
    } else {
      message = 'データの取得に失敗しました';
      icon = Icons.error;
    }
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(trendingRepositoriesProvider(since));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('再試行'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, List<Repository> repos, String title, AppLocalizations l10n) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(trendingRepositoriesProvider(since));
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: repos.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _SectionHeader(title: title, newLabel: l10n.newLabel);
          }
          final repo = repos[index - 1];
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
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String newLabel;

  const _SectionHeader({required this.title, required this.newLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(title, style: AppTypography.subtitle),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              newLabel,
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
