import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final l10n = ref.l10n;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          _SectionHeader(title: l10n.language),
          _LanguageTile(
            currentLocale: currentLocale,
            l10n: l10n,
            onChanged: (locale) {
              ref.read(localeProvider.notifier).state = locale;
            },
          ),
          const Divider(),
          // TODO: 通知機能実装後にUIを復活させる
          // _SectionHeader(title: l10n.notifications),
          // _SwitchTile(...),
          // _TimeTile(...),
          _SectionHeader(title: l10n.filters),
          _SelectTile(
            title: l10n.defaultLanguage,
            value: settings.defaultLanguageFilter ?? l10n.all,
            options: [l10n.all, 'Python', 'JavaScript', 'TypeScript', 'Java', 'Kotlin', 'Swift', 'Go', 'Rust'],
            onChanged: (value) {
              ref.read(appSettingsProvider.notifier).setDefaultLanguage(value == l10n.all ? null : value);
            },
          ),
          _SliderTile(
            title: l10n.minimumStars,
            value: settings.minimumStars,
            min: 0,
            max: 1000,
            divisions: 10,
            onChanged: (value) {
              ref.read(appSettingsProvider.notifier).setMinimumStars(value.toInt());
            },
          ),
          const Divider(),
          _SectionHeader(title: l10n.about),
          _InfoTile(
            title: l10n.version,
            value: '1.0.2',
          ),
          _LinkTile(
            title: l10n.privacyPolicy,
            onTap: () => launchUrl(Uri.parse('https://gittrend-jp.vercel.app/privacy-policy.html')),
          ),
          _LinkTile(
            title: l10n.termsOfService,
            onTap: () => launchUrl(Uri.parse('https://gittrend-jp.vercel.app/terms-of-service.html')),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final AppLocale currentLocale;
  final AppLocalizations l10n;
  final ValueChanged<AppLocale> onChanged;

  const _LanguageTile({
    required this.currentLocale,
    required this.l10n,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        l10n.language,
        style: AppTypography.body.copyWith(color: AppColors.textPrimary),
      ),
      trailing: SegmentedButton<AppLocale>(
        segments: [
          ButtonSegment(
            value: AppLocale.ja,
            label: Text(l10n.languageJapanese),
          ),
          ButtonSegment(
            value: AppLocale.en,
            label: Text(l10n.languageEnglish),
          ),
        ],
        selected: {currentLocale},
        onSelectionChanged: (Set<AppLocale> newSelection) {
          onChanged(newSelection.first);
        },
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    this.subtitle,
    required this.value,
    this.enabled = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        title,
        style: AppTypography.body.copyWith(
          color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTypography.caption,
            )
          : null,
      value: value,
      activeColor: AppColors.primary,
      onChanged: enabled ? onChanged : null,
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String title;
  final TimeOfDay time;
  final bool enabled;
  final VoidCallback onTap;

  const _TimeTile({
    required this.title,
    required this.time,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: AppTypography.body.copyWith(
          color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
      trailing: Text(
        time.format(context),
        style: AppTypography.body.copyWith(
          color: enabled ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
      enabled: enabled,
      onTap: enabled ? onTap : null,
    );
  }
}

class _SelectTile extends StatelessWidget {
  final String title;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _SelectTile({
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: AppTypography.body.copyWith(color: AppColors.textPrimary),
      ),
      trailing: DropdownButton<String>(
        value: options.contains(value) ? value : options.first,
        underline: const SizedBox(),
        style: AppTypography.body.copyWith(color: AppColors.primary),
        onChanged: (newValue) {
          if (newValue != null) onChanged(newValue);
        },
        items: options.map((option) {
          return DropdownMenuItem(value: option, child: Text(option));
        }).toList(),
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final String title;
  final int value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.body.copyWith(color: AppColors.textPrimary),
              ),
              Text(
                value.toString(),
                style: AppTypography.body.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
        Slider(
          value: value.toDouble(),
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const _InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: AppTypography.body.copyWith(color: AppColors.textPrimary),
      ),
      trailing: Text(
        value,
        style: AppTypography.body.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _LinkTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: AppTypography.body.copyWith(color: AppColors.textPrimary),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}
