import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/providers.dart';
import '../../widgets/error_view.dart';
import '../../widgets/repository_card.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksState = ref.watch(bookmarksProvider);
    final l10n = ref.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.savedRepositories),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(bookmarksProvider.notifier).refresh(),
          ),
        ],
      ),
      body: bookmarksState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          error: e,
          l10n: l10n,
          onRetry: () => ref.read(bookmarksProvider.notifier).refresh(),
        ),
        data: (savedRepositories) => savedRepositories.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.bookmark_outline,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noSavedRepositories,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.tapToSave,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () => ref.read(bookmarksProvider.notifier).refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: savedRepositories.length,
                  itemBuilder: (context, index) {
                    final saved = savedRepositories[index];
                    return RepositoryCard(
                      fullName: saved.name ?? 'Unknown',
                      description: saved.description ?? '',
                      stars: saved.stars ?? 0,
                      language: saved.language,
                      tags: const [],
                      onSaveToggle: () async {
                        try {
                          await ref.read(bookmarksProvider.notifier).removeBookmark(saved.repositoryId);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.bookmarkError)),
                            );
                          }
                        }
                      },
                      descriptionJa: saved.descriptionJa,
                      summaryJa: saved.summaryJa,
                      url: saved.url,
                    );
                  },
                ),
              ),
      ),
    );
  }
}
