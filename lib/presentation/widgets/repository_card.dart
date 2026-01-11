import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/logger.dart';
import '../../data/providers/providers.dart';

class RepositoryCard extends StatelessWidget {
  static const String _tag = 'RepositoryCard';
  
  final String fullName;
  final String description;
  final int stars;
  final int? starsToday;
  final String? language;
  final List<String> tags;
  final bool isSaved;
  final VoidCallback? onTap;
  final VoidCallback? onSaveToggle;
  final String? descriptionJa;
  final String? summaryJa;
  final String? url;

  const RepositoryCard({
    super.key,
    required this.fullName,
    required this.description,
    required this.stars,
    this.starsToday,
    this.language,
    this.tags = const [],
    this.isSaved = false,
    this.onTap,
    this.onSaveToggle,
    this.descriptionJa,
    this.summaryJa,
    this.url,
  });

  Future<void> _openGitHub(BuildContext context) async {
    final urlString = url ?? 'https://github.com/$fullName';
    final uri = Uri.parse(urlString);
    
    Logger.debug(_tag, 'Opening GitHub: $urlString');
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        Logger.info(_tag, 'Successfully opened: $urlString');
      } else {
        Logger.warning(_tag, 'Cannot launch URL: $urlString');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('URLを開けませんでした')),
          );
        }
      }
    } catch (e, stack) {
      Logger.error(_tag, 'Failed to open URL: $urlString', e, stack);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('URLを開けませんでした')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayDescription = descriptionJa ?? description;
    final isLoading = descriptionJa == null && summaryJa == null;

    return Semantics(
      container: true,
      label: 'リポジトリ: $fullName, スター数: ${_formatNumber(stars)}${starsToday != null && starsToday! > 0 ? ", 本日 +$starsToday" : ""}, ${language ?? "言語不明"}',
      child: Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openGitHub(context),
                    child: Text(
                      fullName,
                      style: AppTypography.subtitle.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.star,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatNumber(stars),
                      style: AppTypography.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (starsToday != null && starsToday! > 0) ...[
              const SizedBox(height: 4),
              Text(
                '+$starsToday today',
                style: AppTypography.caption.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
            const SizedBox(height: 8),
            if (isLoading)
              Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Loading...',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              )
            else
              Text(
                displayDescription,
                style: AppTypography.body,
              ),
            if (summaryJa != null && summaryJa!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: AppColors.primary.withOpacity(0.8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'README Summary',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      summaryJa!,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (language != null) _LanguageTag(language: language!),
                      ...tags.map((tag) => _Tag(label: tag)),
                    ],
                  ),
                ),
                if (onSaveToggle != null)
                  _BookmarkButton(
                    fullName: fullName,
                    onToggle: onSaveToggle!,
                  ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}

class _LanguageTag extends StatelessWidget {
  final String language;

  const _LanguageTag({required this.language});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.languageColors[language] ?? AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            language,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.caption,
      ),
    );
  }
}

class _BookmarkButton extends ConsumerWidget {
  final String fullName;
  final VoidCallback onToggle;

  const _BookmarkButton({required this.fullName, required this.onToggle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked = ref.watch(bookmarkedIdsProvider).contains(fullName);
    return Semantics(
      button: true,
      label: isBookmarked ? 'ブックマークを解除' : 'ブックマークに追加',
      child: IconButton(
        icon: Icon(
          isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
          color: isBookmarked ? AppColors.primary : AppColors.textSecondary,
        ),
        onPressed: onToggle,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        tooltip: isBookmarked ? 'ブックマークを解除' : 'ブックマークに追加',
      ),
    );
  }
}
