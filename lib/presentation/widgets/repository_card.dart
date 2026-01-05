import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class RepositoryCard extends StatelessWidget {
  final String fullName;
  final String description;
  final int stars;
  final int? starsToday;
  final String? language;
  final List<String> tags;
  final bool isSaved;
  final VoidCallback? onTap;
  final VoidCallback? onSaveToggle;

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
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      fullName,
                      style: AppTypography.subtitle.copyWith(
                        color: AppColors.primary,
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
              Text(
                description,
                style: AppTypography.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (language != null) _LanguageTag(language: language!),
                  ...tags.map((tag) => _Tag(label: tag)),
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
