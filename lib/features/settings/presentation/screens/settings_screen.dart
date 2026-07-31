import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_controller.dart';
import '../../../../core/database/user_settings_repository.dart';
import '../../../../core/widgets/custom_card.dart';

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
    final feedbackController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Geri Bildirim Gönder'),
        content: TextField(
          controller: feedbackController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Görüş ve önerilerinizi yazın...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Geri bildiriminiz için teşekkürler!')),
              );
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gizlilik Politikası'),
        content: const SingleChildScrollView(
          child: Text(
            'Takı Sandığım, girdiğiniz isim, mail ve hediye kayıtları gibi '
            'verileri yalnızca uygulama içindeki hesaplamalar ve yedekleme '
            'amacıyla kullanır. Verileriniz üçüncü taraflarla paylaşılmaz ve '
            'cihazınızda güvenli şekilde saklanır. Uygulama ayarlarından '
            'dilediğiniz zaman verilerinizi güncelleyebilir veya '
            'silebilirsiniz.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
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
                    title: 'Karanlık Mod',
                    subtitle: 'Uygulama genelinde koyu temayı etkinleştirir',
                    value: themeMode == ThemeMode.dark,
                    onChanged: (value) =>
                        ThemeController.instance.setDark(value),
                  ),
                ),
                const Divider(height: 24),
                _switchRow(
                  icon: Icons.notifications_outlined,
                  title: 'Bildirimler',
                  subtitle: 'Yaklaşan düğün hatırlatmaları',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                    _settingsRepository.setNotificationsEnabled(value);
                  },
                ),
                const Divider(height: 24),
                _settingRow(
                  icon: Icons.currency_lira,
                  title: 'Altın Kuru',
                  subtitle: 'Güncel gram altın kuruna göre hesaplanır',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yardım',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _sendFeedback,
                  child: _settingRow(
                    icon: Icons.feedback_outlined,
                    title: 'Geri Bildirim Gönder',
                    subtitle: 'Görüş ve önerilerinizi bizimle paylaşın',
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                const Divider(height: 24),
                _settingRow(
                  icon: Icons.info_outline,
                  title: 'Uygulama Versiyonu',
                  subtitle: 'Sürüm 0.1.0',
                ),
                const Divider(height: 24),
                InkWell(
                  onTap: _showPrivacyPolicy,
                  child: _settingRow(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Gizlilik Politikası',
                    subtitle: 'Verilerinizin nasıl kullanıldığını görüntüleyin',
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textMuted,
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
                const Text(
                  'Geliştiriciler',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                _settingRow(
                  icon: Icons.code,
                  title: 'Levent ASLAN',
                  subtitle: 'Geliştirici',
                ),
                const Divider(height: 24),
                _settingRow(
                  icon: Icons.code,
                  title: 'Halime ÖZOYMAK',
                  subtitle: 'Geliştirici',
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
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
