import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/user_settings_repository.dart';
import '../../../../core/network/currency_rate_service.dart';
import '../../../../core/network/gold_rate_service.dart';
import '../../../../core/utils/currency_converter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/name_capitalization_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../dashboard/data/models/gift_enums.dart';
import '../../../dashboard/presentation/widgets/direction_toggle.dart';
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

enum _CashInputMode { tl, foreign }

class _AddGiftFormState extends State<_AddGiftForm> {
  final _formKey = GlobalKey<FormState>();
  final _personNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _cashAmountController = TextEditingController();
  final _foreignAmountController = TextEditingController();
  final _noteController = TextEditingController();
  final _goldRateService = GoldRateService();
  final _currencyRateService = CurrencyRateService();
  final _settingsRepository = UserSettingsRepository();

  GiftType _giftType = GiftType.quarterGold;
  GiftDirection _direction = GiftDirection.received;
  EventType _eventType = EventType.wedding;
  DateTime _date = DateTime.now();
  double? _goldRateTl;
  bool _isLoadingRate = true;

  _CashInputMode _cashInputMode = _CashInputMode.tl;
  SupportedCurrency _currency = SupportedCurrency.all.first;
  double? _currencyRateTl;
  bool _isLoadingCurrencyRate = false;

  void _selectEventType(EventType eventType) {
    final savedDate = _settingsRepository.getEventDate(eventType);
    setState(() {
      _eventType = eventType;
      if (savedDate != null) _date = savedDate;
    });
  }

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

  double get _foreignValueTl {
    final amount = double.tryParse(
      _foreignAmountController.text.replaceAll(',', '.'),
    );
    if (amount == null || _currencyRateTl == null) return 0;
    return amount * _currencyRateTl!;
  }

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() => setState(() {}));
    _foreignAmountController.addListener(() => setState(() {}));
    final savedDate = _settingsRepository.getEventDate(_eventType);
    if (savedDate != null) _date = savedDate;
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

  Future<void> _loadCurrencyRate() async {
    setState(() => _isLoadingCurrencyRate = true);
    final rate = await _currencyRateService.getRateTl(_currency.code);
    if (!mounted) return;
    setState(() {
      _currencyRateTl = rate;
      _isLoadingCurrencyRate = false;
    });
  }

  void _selectCashInputMode(_CashInputMode mode) {
    setState(() => _cashInputMode = mode);
    if (mode == _CashInputMode.foreign && _currencyRateTl == null) {
      _loadCurrencyRate();
    }
  }

  void _selectCurrency(SupportedCurrency currency) {
    setState(() {
      _currency = currency;
      _currencyRateTl = null;
    });
    _loadCurrencyRate();
  }

  @override
  void dispose() {
    _personNameController.dispose();
    _amountController.dispose();
    _cashAmountController.dispose();
    _foreignAmountController.dispose();
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
    final String? currencyCode;
    final double? currencyRateTl;

    if (isCash && _cashInputMode == _CashInputMode.foreign) {
      final value = double.parse(
        _foreignAmountController.text.replaceAll(',', '.'),
      );
      amount = value;
      estimatedValueTl = _foreignValueTl;
      goldRateTl = null;
      currencyCode = _currency.code;
      currencyRateTl = _currencyRateTl;
    } else if (isCash) {
      final value = double.parse(
        _cashAmountController.text.replaceAll(',', '.'),
      );
      amount = value;
      estimatedValueTl = value;
      goldRateTl = null;
      currencyCode = null;
      currencyRateTl = null;
    } else {
      amount = double.parse(_amountController.text.replaceAll(',', '.'));
      estimatedValueTl = _calculatedValue;
      goldRateTl = _goldRateTl;
      currencyCode = null;
      currencyRateTl = null;
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
        currencyCode: currencyCode,
        currencyRateTl: currencyRateTl,
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
          DirectionToggle(
            selected: _direction,
            receivedLabel: 'Bize Takılan',
            onChanged: (direction) => setState(() => _direction = direction),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Kişi Adı',
            controller: _personNameController,
            prefixIcon: Icons.person_outline,
            inputFormatters: const [NameCapitalizationFormatter()],
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
            onChanged: (v) => _selectEventType(v!),
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
                          style: TextStyle(color: AppColors.muted(context), fontSize: 15, fontWeight: FontWeight.w500),
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
          ] else ...[
            SegmentedButton<_CashInputMode>(
              segments: const [
                ButtonSegment(value: _CashInputMode.tl, label: Text('TL')),
                ButtonSegment(
                  value: _CashInputMode.foreign,
                  label: Text('Döviz'),
                ),
              ],
              selected: {_cashInputMode},
              onSelectionChanged: (s) => _selectCashInputMode(s.first),
            ),
            const SizedBox(height: 12),
            if (_cashInputMode == _CashInputMode.tl)
              CustomTextField(
                label: 'Tutar (TL)',
                controller: _cashAmountController,
                prefixIcon: Icons.payments_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) =>
                    (v == null ||
                        double.tryParse(v.replaceAll(',', '.')) == null)
                    ? 'Geçerli bir tutar girin'
                    : null,
              )
            else ...[
              DropdownButtonFormField<SupportedCurrency>(
                initialValue: _currency,
                decoration: const InputDecoration(labelText: 'Para Birimi'),
                items: SupportedCurrency.all
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text('${c.label} (${c.code})'),
                      ),
                    )
                    .toList(),
                onChanged: (c) => _selectCurrency(c!),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Tutar (${_currency.code})',
                controller: _foreignAmountController,
                prefixIcon: Icons.currency_exchange,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) =>
                    (v == null ||
                        double.tryParse(v.replaceAll(',', '.')) == null)
                    ? 'Geçerli bir tutar girin'
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
                child: _isLoadingCurrencyRate
                    ? const Text('Güncel kur alınıyor...')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Güncel kur: 1 ${_currency.code} = '
                            '${CurrencyConverter.formatTl(_currencyRateTl ?? 0)}',
                            style: TextStyle(color: AppColors.muted(context), fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'TL karşılığı: '
                            '${CurrencyConverter.formatTl(_foreignValueTl)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ],
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
