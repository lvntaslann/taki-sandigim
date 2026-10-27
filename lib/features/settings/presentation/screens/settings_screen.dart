import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_controller.dart';
import '../../../../core/database/user_settings_repository.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settingsRepository = UserSettingsRepository();
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = _settingsRepository.areNotificationsEnabled();
  }

  void _sendFeedback() {
    final l10n = AppLocalizations.of(context);
    final feedbackController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.sendFeedback),
        content: TextField(
          controller: feedbackController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: l10n.feedbackHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.feedbackThanks)),
              );
            },
            child: Text(l10n.send),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.privacyPolicy),
        content: SingleChildScrollView(
          child: Text(l10n.privacyPolicyBody),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CustomCard(
            child: Column(
              children: [
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: ThemeController.instance,
                  builder: (context, themeMode, _) => _switchRow(
                    icon: Icons.dark_mode_outlined,
                    title: l10n.darkMode,
                    subtitle: l10n.darkModeSubtitle,
                    value: themeMode == ThemeMode.dark,
                    onChanged: (value) =>
                        ThemeController.instance.setDark(value),
                  ),
                ),
                const Divider(height: 24),
                _switchRow(
                  icon: Icons.notifications_outlined,
                  title: l10n.notifications,
                  subtitle: l10n.notificationsSubtitle,
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                    _settingsRepository.setNotificationsEnabled(value);
                  },
                ),
                const Divider(height: 24),
                _settingRow(
                  icon: Icons.currency_lira,
                  title: l10n.goldRate,
                  subtitle: l10n.goldRateSubtitle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.help,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _sendFeedback,
                  child: _settingRow(
                    icon: Icons.feedback_outlined,
                    title: l10n.sendFeedback,
                    subtitle: l10n.sendFeedbackSubtitle,
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColors.muted(context),
                    ),
                  ),
                ),
                const Divider(height: 24),
                _settingRow(
                  icon: Icons.info_outline,
                  title: l10n.appVersion,
                  subtitle: l10n.versionValue('0.1.0'),
                ),
                const Divider(height: 24),
                InkWell(
                  onTap: _showPrivacyPolicy,
                  child: _settingRow(
                    icon: Icons.privacy_tip_outlined,
                    title: l10n.privacyPolicy,
                    subtitle: l10n.privacyPolicySubtitle,
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColors.muted(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.developers,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                _settingRow(
                  icon: Icons.code,
                  title: 'Levent ASLAN',
                  subtitle: l10n.developer,
                ),
                const Divider(height: 24),
                _settingRow(
                  icon: Icons.code,
                  title: 'Halime ÖZOYMAK',
                  subtitle: l10n.developer,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: _settingRow(icon: icon, title: title, subtitle: subtitle),
        ),
        Switch(
          value: value,
          activeThumbColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _settingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.muted(context),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }
}
