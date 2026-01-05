import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _japaneseOnlyNotifications = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 8, minute: 0);
  String _defaultLanguage = 'All';
  int _minimumStars = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _SectionHeader(title: 'Notifications'),
          _SwitchTile(
            title: 'Daily Trending Alert',
            subtitle: 'Get notified about trending repos',
            value: _notificationsEnabled,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
          ),
          _TimeTile(
            title: 'Notification Time',
            time: _notificationTime,
            enabled: _notificationsEnabled,
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _notificationTime,
              );
              if (time != null) {
                setState(() => _notificationTime = time);
              }
            },
          ),
          _SwitchTile(
            title: 'Japanese Repos Only',
            subtitle: 'Only notify for Japanese repos',
            value: _japaneseOnlyNotifications,
            enabled: _notificationsEnabled,
            onChanged: (value) => setState(() => _japaneseOnlyNotifications = value),
          ),
          const Divider(),
          _SectionHeader(title: 'Filters'),
          _SelectTile(
            title: 'Default Language',
            value: _defaultLanguage,
            options: const ['All', 'Python', 'JavaScript', 'TypeScript', 'Java', 'Kotlin', 'Swift', 'Go', 'Rust'],
            onChanged: (value) => setState(() => _defaultLanguage = value),
          ),
          _SliderTile(
            title: 'Minimum Stars',
            value: _minimumStars,
            min: 0,
            max: 1000,
            divisions: 10,
            onChanged: (value) => setState(() => _minimumStars = value.toInt()),
          ),
          const Divider(),
          _SectionHeader(title: 'About'),
          const _InfoTile(
            title: 'Version',
            value: '1.0.0',
          ),
          _LinkTile(
            title: 'Privacy Policy',
            onTap: () {},
          ),
          _LinkTile(
            title: 'Terms of Service',
            onTap: () {},
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
        value: value,
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
