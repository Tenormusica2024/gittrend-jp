import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/repository.dart';
import '../../../data/providers/providers.dart';

class RepositoryDetailScreen extends ConsumerStatefulWidget {
  final Repository repository;

  const RepositoryDetailScreen({
    super.key,
    required this.repository,
  });

  @override
  ConsumerState<RepositoryDetailScreen> createState() => _RepositoryDetailScreenState();
}

class _RepositoryDetailScreenState extends ConsumerState<RepositoryDetailScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _descriptionJa;
  String? _summaryJa;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    try {
      final api = ref.read(githubApiProvider);
      final result = await api.getRepoSummary(
        widget.repository.fullName,
        widget.repository.description,
      );
      if (mounted) {
        setState(() {
          _descriptionJa = result['descriptionJa'];
          _summaryJa = result['summaryJa'];
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.l10n;
    final repo = widget.repository;
    return Scaffold(
      appBar: AppBar(
        title: Text(repo.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _launchUrl(repo.url),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              repo.fullName,
              style: AppTypography.h1.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatsRow(repo, l10n),
            const SizedBox(height: 24),
            _buildSection(
              title: l10n.description,
              content: repo.description,
              noContentText: l10n.noDescriptionAvailable,
            ),
            const SizedBox(height: 16),
            _buildJapaneseSummarySection(l10n),
            const SizedBox(height: 24),
            _buildGitHubButton(repo.url, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(Repository repo, AppLocalizations l10n) {
    return Row(
      children: [
        _buildStatChip(
          icon: Icons.star_rounded,
          label: _formatNumber(repo.stars),
          color: AppColors.star,
        ),
        const SizedBox(width: 12),
        if (repo.starsToday > 0)
          _buildStatChip(
            icon: Icons.trending_up,
            label: l10n.starsToday(repo.starsToday),
            color: AppColors.success,
          ),
        const SizedBox(width: 12),
        if (repo.language != null)
          _buildLanguageChip(repo.language!),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageChip(String language) {
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

  Widget _buildSection({required String title, required String content, required String noContentText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.subtitle.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content.isEmpty ? noContentText : content,
          style: AppTypography.body,
        ),
      ],
    );
  }

  Widget _buildJapaneseSummarySection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.translate,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.japaneseSummary,
                style: AppTypography.subtitle.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_hasError)
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.textSecondary,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.translationFailed,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _hasError = false;
                      });
                      _loadSummary();
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            )
          else ...[
            Text(
              l10n.description,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _descriptionJa ?? l10n.translationUnavailable,
              style: AppTypography.body.copyWith(
                color: _descriptionJa != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.readmeSummary,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _summaryJa ?? l10n.summaryUnavailable,
              style: AppTypography.body.copyWith(
                color: _summaryJa != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGitHubButton(String url, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _launchUrl(url),
        icon: const Icon(Icons.open_in_browser),
        label: Text(l10n.viewOnGitHub),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}
