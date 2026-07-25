import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/gold_rate_service.dart';
import '../../../../core/utils/currency_converter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../dashboard/data/models/gift_enums.dart';
import '../../../scanner/presentation/widgets/scanner_body.dart';
import '../../data/tracker_repository.dart';
import '../bloc/tracker_bloc.dart';

class AddGiftScreen extends StatelessWidget {
  const AddGiftScreen({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Yeni Kayıt Ekle'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Yeni Ekle'),
              Tab(text: 'Defter/Davetiye Tara'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BlocProvider(
              create: (_) =>
                  TrackerBloc(trackerRepository: TrackerRepository()),
              child: const _AddGiftForm(),
            ),
            const ScannerBody(),
          ],
        ),
      ),
    );
  }
}

class _AddGiftForm extends StatefulWidget {
  const _AddGiftForm();

  @override
  State<_AddGiftForm> createState() => _AddGiftFormState();
}

class _AddGiftFormState extends State<_AddGiftForm> {
  final _formKey = GlobalKey<FormState>();
  final _personNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _cashAmountController = TextEditingController();
  final _noteController = TextEditingController();
  final _goldRateService = GoldRateService();

  GiftType _giftType = GiftType.quarterGold;
  GiftDirection _direction = GiftDirection.received;
  EventType _eventType = EventType.wedding;
  DateTime _date = DateTime.now();
  double? _goldRateTl;
  bool _isLoadingRate = true;

  static const _manualAmountTypes = {GiftType.cash, GiftType.other};

  bool get _isGoldBased => !_manualAmountTypes.contains(_giftType);

  double get _calculatedValue {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || _goldRateTl == null) return 0;
    return CurrencyConverter.giftValueTl(
      giftType: _giftType,
      amount: amount,
      goldRateTl: _goldRateTl!,
    );
  }

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() => setState(() {}));
    _loadRate();
  }

  Future<void> _loadRate() async {
    final rate = await _goldRateService.getGoldRateTl();
    if (!mounted) return;
    setState(() {
      _goldRateTl = rate;
      _isLoadingRate = false;
    });
  }

  @override
  void dispose() {
    _personNameController.dispose();
    _amountController.dispose();
    _cashAmountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final bool isCash = _manualAmountTypes.contains(_giftType);
    final double amount;
    final double estimatedValueTl;
    final double? goldRateTl;

    if (isCash) {
      final value = double.parse(
        _cashAmountController.text.replaceAll(',', '.'),
      );
      amount = value;
      estimatedValueTl = value;
      goldRateTl = null;
    } else {
      amount = double.parse(_amountController.text.replaceAll(',', '.'));
      estimatedValueTl = _calculatedValue;
      goldRateTl = _goldRateTl;
    }

    context.read<TrackerBloc>().add(
      TrackerGiftAdded(
        personName: _personNameController.text.trim(),
        giftType: _giftType,
        amount: amount,
        estimatedValueTl: estimatedValueTl,
        direction: _direction,
        date: _date,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        goldRateTl: goldRateTl,
        eventType: _eventType,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<GiftDirection>(
            segments: const [
              ButtonSegment(
                value: GiftDirection.received,
                label: Text('Bize Takılan'),
              ),
              ButtonSegment(
                value: GiftDirection.given,
                label: Text('Bizim Taktığımız'),
              ),
            ],
            selected: {_direction},
            onSelectionChanged: (s) => setState(() => _direction = s.first),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Kişi Adı',
            controller: _personNameController,
            prefixIcon: Icons.person_outline,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Kişi adı gerekli' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<EventType>(
            initialValue: _eventType,
            decoration: const InputDecoration(labelText: 'Nerede Takıldı'),
            items: EventType.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
                .toList(),
            onChanged: (v) => setState(() => _eventType = v!),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<GiftType>(
            initialValue: _giftType,
            decoration: const InputDecoration(labelText: 'Takı Türü'),
            items: GiftType.values
                .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                .toList(),
            onChanged: (v) => setState(() => _giftType = v!),
          ),
          const SizedBox(height: 16),
          if (_isGoldBased) ...[
            CustomTextField(
              label: 'Miktar (adet/gram)',
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) =>
                  (v == null || double.tryParse(v.replaceAll(',', '.')) == null)
                  ? 'Geçerli bir miktar girin'
                  : null,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: _isLoadingRate
                  ? const Text('Güncel kur alınıyor...')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bugünkü gram altın kuru: '
                          '${CurrencyConverter.formatTl(_goldRateTl ?? 0)}',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hesaplanan değer: '
                          '${CurrencyConverter.formatTl(_calculatedValue)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
            ),
          ] else
            CustomTextField(
              label: 'Tutar (TL)',
              controller: _cashAmountController,
              prefixIcon: Icons.payments_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) =>
                  (v == null || double.tryParse(v.replaceAll(',', '.')) == null)
                  ? 'Geçerli bir tutar girin'
                  : null,
            ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Tarih',
            readOnly: true,
            onTap: _pickDate,
            prefixIcon: Icons.calendar_today_outlined,
            controller: TextEditingController(
              text: DateFormatter.shortDate(_date),
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Not (opsiyonel)',
            controller: _noteController,
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          CustomButton(label: 'Kaydet', onPressed: _save),
        ],
      ),
    );
  }
}
