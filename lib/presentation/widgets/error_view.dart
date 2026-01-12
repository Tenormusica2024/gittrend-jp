import 'package:flutter/material.dart';
import '../../core/errors/api_exception.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ErrorView extends StatelessWidget {
  final Object error;
  final AppLocalizations l10n;
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    required this.error,
    required this.l10n,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    String message;
    IconData icon;

    if (error is ApiConnectionException) {
      message = l10n.connectionError;
      icon = Icons.wifi_off;
    } else if (error is ApiNotFoundException) {
      message = (error as ApiNotFoundException).message;
      icon = Icons.error_outline;
    } else if (error is ApiServerException) {
      message = l10n.serverError;
      icon = Icons.cloud_off;
    } else if (error is ApiException) {
      message = (error as ApiException).message;
      icon = Icons.warning_amber;
    } else {
      message = l10n.genericError;
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
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
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
}
