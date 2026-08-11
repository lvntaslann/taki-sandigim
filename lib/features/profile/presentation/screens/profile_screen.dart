import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/user_settings_repository.dart';
import '../../../../core/services/purchase_service.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../dashboard/data/models/gift_enums.dart';
import '../../../dashboard/data/repositories/gift_repository.dart';
import '../../../dashboard/data/repositories/wedding_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _settingsRepository = UserSettingsRepository();
  final _giftRepository = GiftRepository();
  final _weddingRepository = WeddingRepository();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _weddingDateController;
  DateTime? _eventDate;
  String? _photoBase64;
  EventType _eventType = EventType.wedding;
  String? _savedName;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: _settingsRepository.getName() ?? '',
    );
    _emailController = TextEditingController(
      text: _settingsRepository.getEmail() ?? '',
    );
    _eventDate = _settingsRepository.getEventDate(_eventType);
    _weddingDateController = TextEditingController(
      text: _eventDate == null ? '' : _formatDate(_eventDate!),
    );
    _photoBase64 = _settingsRepository.getPhotoBase64();
    _savedName = _settingsRepository.getName();
  }

  String _formatDate(DateTime date) =>
      DateFormat('d MMMM y', 'tr_TR').format(date);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _weddingDateController.dispose();
    super.dispose();
  }

  void _saveName() {
    final name = _nameController.text.trim();
    _settingsRepository.setName(name);
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('İsim kaydedildi.')),
    );
    setState(() => _savedName = name);
  }

  void _saveEmail() {
    final email = _emailController.text.trim();
    _settingsRepository.setEmail(email);
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mail adresi kaydedildi.')),
    );
  }

  Future<void> _pickWeddingDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? now,
      firstDate: DateTime(now.year - 80),
      lastDate: DateTime(now.year + 10),
    );
    if (picked == null) return;
    setState(() {
      _eventDate = picked;
      _weddingDateController.text = _formatDate(picked);
    });
    await _settingsRepository.setEventDate(_eventType, picked);
  }

  void _selectEventType(EventType eventType) {
    final date = _settingsRepository.getEventDate(eventType);
    setState(() {
      _eventType = eventType;
      _eventDate = date;
      _weddingDateController.text = date == null ? '' : _formatDate(date);
    });
  }

  void _openReports() => context.push(AppRoutes.reports);

  void _openPremium() => context.push(AppRoutes.premium);

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final base64 = base64Encode(bytes);
    setState(() => _photoBase64 = base64);
    await _settingsRepository.setPhotoBase64(base64);
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    context.go(AppRoutes.onboarding);
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text(
          'Hesabınızı silmek, profil bilgilerinizi ve tüm takı kayıtlarınızı kalıcı olarak silecektir. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Hesabı Sil',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await _settingsRepository.clearAll();
    await _giftRepository.clearAll();
    await _weddingRepository.clearAll();

    if (!mounted) return;
    context.go(AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickPhoto,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    backgroundImage: _photoBase64 != null
                        ? MemoryImage(base64Decode(_photoBase64!))
                        : null,
                    child: _photoBase64 == null
                        ? const Icon(
                            Icons.person,
                            size: 42,
                            color: AppColors.secondary,
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_savedName != null && _savedName!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                _savedName!,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
              ),
            ),
          ],
          const SizedBox(height: 20),
          ValueListenableBuilder<bool>(
            valueListenable: PurchaseService.instance.isPremium,
            builder: (context, isPremium, _) =>
                isPremium ? _premiumActiveBadge() : _premiumBanner(),
          ),
          const SizedBox(height: 24),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Adınız',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ana Sayfa\'daki selamlamada kullanılır.',
                  style: TextStyle(
                    color: AppColors.muted(context),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'İsim',
                        controller: _nameController,
                        prefixIcon: Icons.badge_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 100,
                      child: CustomButton(label: 'Kaydet', onPressed: _saveName),
                    ),
                  ],
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
                  'Mail Adresi',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Yedekleme ve bildirimler için kullanılır.',
                  style: TextStyle(
                    color: AppColors.muted(context),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Mail',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 100,
                      child: CustomButton(
                        label: 'Kaydet',
                        onPressed: _saveEmail,
                      ),
                    ),
                  ],
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
                  'Özel Günlerinizin Tarihi',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: EventType.values
                      .map(
                        (option) => ChoiceChip(
                          label: Text(option.label),
                          selected: _eventType == option,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: _eventType == option
                                ? Colors.white
                                : AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) => _selectEventType(option),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: '${_eventType.label} Tarihi',
                  controller: _weddingDateController,
                  readOnly: true,
                  prefixIcon: Icons.calendar_month_outlined,
                  hintText: 'Tarih seçin',
                  onTap: _pickWeddingDate,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CustomCard(
            onTap: _openReports,
            child: Row(
              children: [
                const Icon(Icons.description_outlined, color: AppColors.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Takı Listesi Raporları',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'PDF, Excel olarak indir veya paylaş.',
                        style: TextStyle(
                          color: AppColors.muted(context),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.chevron_right, color: AppColors.muted(context)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          CustomCard(
            child: Row(
              children: [
                const Icon(Icons.logout, color: AppColors.secondary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Çıkış Yap',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Hesabınızdan çıkış yapın.',
                        style: TextStyle(
                          color: AppColors.muted(context),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: CustomButton(
                    label: 'Çıkış',
                    onPressed: _confirmLogout,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CustomCard(
            child: Row(
              children: [
                const Icon(Icons.delete_forever, color: Colors.red),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hesabı Sil',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red),
                      ),
                      Text(
                        'Tüm verileriniz kalıcı olarak silinir.',
                        style: TextStyle(
                          color: AppColors.muted(context),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    onPressed: _confirmDeleteAccount,
                    child: const Text('Sil'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _premiumBanner() {
    return InkWell(
      onTap: _openPremium,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -30,
                right: -20,
                child: Icon(
                  Icons.workspace_premium,
                  size: 140,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              Positioned(
                bottom: -36,
                right: 56,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.workspace_premium,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Premium\'a Geç',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Reklamsız deneyim, daha fazla tarama hakkı ve esnek dışa aktarım',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _premiumActiveBadge() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.secondary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -30,
              right: -20,
              child: Icon(
                Icons.workspace_premium,
                size: 140,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Premium Aktif',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 19,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Reklamsız ve sınırsız kullanım keyfini çıkarıyorsun.',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
