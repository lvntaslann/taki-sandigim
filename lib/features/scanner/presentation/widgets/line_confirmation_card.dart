import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/currency_rate_service.dart';
import '../../../../core/network/gold_rate_service.dart';
import '../../../../core/utils/currency_converter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../dashboard/data/models/gift_enums.dart';
import '../../domain/gift_type_guesser.dart';
import '../../domain/notebook_line.dart';

enum _CashInputMode { tl, foreign }

class LineConfirmationCard extends StatefulWidget {
  const LineConfirmationCard({
    super.key,
    required this.line,
    required this.onAdd,
    required this.onSkip,
  });

  final NotebookLine line;
  final void Function({
    required String personName,
    required GiftType giftType,
    required double amount,
    required double estimatedValueTl,
    required GiftDirection direction,
    double? goldRateTl,
    required RelationType relationType,
    String? currencyCode,
    double? currencyRateTl,
  }) onAdd;
  final VoidCallback onSkip;

  @override
  State<LineConfirmationCard> createState() => _LineConfirmationCardState();
}

class _LineConfirmationCardState extends State<LineConfirmationCard> {
  late final TextEditingController _personNameController;
  late final TextEditingController _amountController;
  final TextEditingController _cashAmountController = TextEditingController();
  final TextEditingController _foreignAmountController = TextEditingController();
  final GoldRateService _goldRateService = GoldRateService();
  final CurrencyRateService _currencyRateService = CurrencyRateService();

  late GiftType _giftType;
  GiftDirection _direction = GiftDirection.received;
  RelationType _relationType = RelationType.friend;
  double? _goldRateTl;

  _CashInputMode _cashInputMode = _CashInputMode.tl;
  SupportedCurrency _currency = SupportedCurrency.all.first;
  double? _currencyRateTl;

  static const _manualAmountTypes = {GiftType.cash, GiftType.other};

  bool get _isGoldBased => !_manualAmountTypes.contains(_giftType);

  double get _calculatedValue {
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || _goldRateTl == null) return 0;
    return CurrencyConverter.giftValueTl(
      giftType: _giftType,
      amount: amount,
      goldRateTl: _goldRateTl!,
    );
  }

  double get _foreignValueTl {
    final amount =
        double.tryParse(_foreignAmountController.text.replaceAll(',', '.'));
    if (amount == null || _currencyRateTl == null) return 0;
    return amount * _currencyRateTl!;
  }

  @override
  void initState() {
    super.initState();
    _personNameController = TextEditingController(text: widget.line.personName);
    _amountController = TextEditingController(
      text: (widget.line.amount ?? 1).toString(),
    );
    if (widget.line.amount != null) {
      _cashAmountController.text = widget.line.amount.toString();
      _foreignAmountController.text = widget.line.amount.toString();
    }
    _giftType = GiftTypeGuesser.guess(widget.line.giftDescription);
    final detectedCurrency =
        GiftTypeGuesser.guessCurrencyCode(widget.line.giftDescription);
    if (detectedCurrency != null) {
      _cashInputMode = _CashInputMode.foreign;
      _currency = SupportedCurrency.all
          .firstWhere((c) => c.code == detectedCurrency, orElse: () => _currency);
      _loadCurrencyRate();
    }
    _amountController.addListener(() => setState(() {}));
    _foreignAmountController.addListener(() => setState(() {}));
    _goldRateService.getGoldRateTl().then((rate) {
      if (mounted) setState(() => _goldRateTl = rate);
    });
  }

  Future<void> _loadCurrencyRate() async {
    final rate = await _currencyRateService.getRateTl(_currency.code);
    if (mounted) setState(() => _currencyRateTl = rate);
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
    super.dispose();
  }

  void _warn(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _add() {
    final personName = _personNameController.text.trim();
    if (personName.isEmpty) return _warn('Kişi adı boş olamaz.');

    if (_isGoldBased) {
      final amount =
          double.tryParse(_amountController.text.replaceAll(',', '.'));
      if (amount == null) return _warn('Geçerli bir miktar girin.');
      widget.onAdd(
        personName: personName,
        giftType: _giftType,
        amount: amount,
        estimatedValueTl: _calculatedValue,
        direction: _direction,
        goldRateTl: _goldRateTl,
        relationType: _relationType,
      );
    } else if (_cashInputMode == _CashInputMode.foreign) {
      final amount =
          double.tryParse(_foreignAmountController.text.replaceAll(',', '.'));
      if (amount == null) return _warn('Geçerli bir tutar girin.');
      widget.onAdd(
        personName: personName,
        giftType: _giftType,
        amount: amount,
        estimatedValueTl: _foreignValueTl,
        direction: _direction,
        relationType: _relationType,
        currencyCode: _currency.code,
        currencyRateTl: _currencyRateTl,
      );
    } else {
      final amount =
          double.tryParse(_cashAmountController.text.replaceAll(',', '.'));
      if (amount == null) return _warn('Geçerli bir tutar girin.');
      widget.onAdd(
        personName: personName,
        giftType: _giftType,
        amount: amount,
        estimatedValueTl: amount,
        direction: _direction,
        relationType: _relationType,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.document_scanner_outlined,
                  color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Taranan: "${widget.line.rawText}"',
                  style: TextStyle(
                    color: AppColors.muted(context),
                    fontStyle: FontStyle.italic,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Kişi Adı',
            controller: _personNameController,
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<RelationType>(
            initialValue: _relationType,
            decoration: const InputDecoration(labelText: 'İlişki'),
            items: RelationType.values
                .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                .toList(),
            onChanged: (v) => setState(() => _relationType = v!),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<GiftType>(
            initialValue: _giftType,
            decoration: const InputDecoration(labelText: 'Takı Türü'),
            items: GiftType.values
                .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                .toList(),
            onChanged: (v) => setState(() => _giftType = v!),
          ),
          const SizedBox(height: 12),
          if (_isGoldBased) ...[
            CustomTextField(
              label: 'Miktar (adet/gram)',
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            Text(
              _goldRateTl == null
                  ? 'Kur alınıyor...'
                  : 'Hesaplanan değer: ${CurrencyConverter.formatTl(_calculatedValue)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              Text(
                _currencyRateTl == null
                    ? 'Kur alınıyor...'
                    : 'TL karşılığı: ${CurrencyConverter.formatTl(_foreignValueTl)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Atla',
                  variant: CustomButtonVariant.outline,
                  onPressed: widget.onSkip,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  label: 'Ekle',
                  icon: Icons.check,
                  onPressed: _add,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
