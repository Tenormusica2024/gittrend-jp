import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/datasources/github_api.dart';
import '../../../data/models/repository.dart';

class RepositoryDetailScreen extends StatefulWidget {
  final Repository repository;

  const RepositoryDetailScreen({
    super.key,
    required this.repository,
  });

  @override
  State<RepositoryDetailScreen> createState() => _RepositoryDetailScreenState();
}

class _RepositoryDetailScreenState extends State<RepositoryDetailScreen> {
  final GitHubApi _api = GitHubApi();
  bool _isLoading = true;
  String? _descriptionJa;
  String? _summaryJa;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final result = await _api.getRepoSummary(
      widget.repository.fullName,
      widget.repository.description,
    );
    if (mounted) {
      setState(() {
        _descriptionJa = result['descriptionJa'];
        _summaryJa = result['summaryJa'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            _buildStatsRow(repo),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Description',
              content: repo.description,
            ),
            const SizedBox(height: 16),
            _buildJapaneseSummarySection(),
            const SizedBox(height: 24),
            _buildGitHubButton(repo.url),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(Repository repo) {
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
            label: '+${repo.starsToday} today',
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

  Widget _buildSection({required String title, required String content}) {
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
          content.isEmpty ? 'No description available' : content,
          style: AppTypography.body,
        ),
      ],
    );
  }

  Widget _buildJapaneseSummarySection() {
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
                'Japanese Summary',
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
          else ...[
            Text(
              'Description',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _descriptionJa ?? 'Translation unavailable',
              style: AppTypography.body.copyWith(
                color: _descriptionJa != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'README Summary',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _summaryJa ?? 'Summary unavailable',
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

  Widget _buildGitHubButton(String url) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _launchUrl(url),
        icon: const Icon(Icons.open_in_browser),
        label: const Text('View on GitHub'),
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
