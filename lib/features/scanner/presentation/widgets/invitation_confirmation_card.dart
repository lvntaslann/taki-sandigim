import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/invitation_info.dart';

class InvitationConfirmationCard extends StatefulWidget {
  const InvitationConfirmationCard({
    super.key,
    required this.info,
    required this.onSave,
  });

  final InvitationInfo info;
  final void Function({
    required String title,
    required DateTime date,
    String? time,
    String? location,
  }) onSave;

  @override
  State<InvitationConfirmationCard> createState() =>
      _InvitationConfirmationCardState();
}

class _InvitationConfirmationCardState
    extends State<InvitationConfirmationCard> {
  late final TextEditingController _titleController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _locationController;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.info.title);
    _date = widget.info.date;
    _dateController = TextEditingController(text: _formattedDate);
    _timeController = TextEditingController(text: widget.info.time ?? '');
    _locationController = TextEditingController(text: widget.info.location ?? '');
  }

  String get _formattedDate =>
      _date == null ? '' : DateFormat.yMMMMd().format(_date!);

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _warn(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _dateController.text = _formattedDate;
    });
  }

  void _save() {
    final l10n = AppLocalizations.of(context);
    final title = _titleController.text.trim();
    if (title.isEmpty) return _warn(l10n.coupleNameEmpty);
    if (_date == null) return _warn(l10n.pleasePickDate);

    widget.onSave(
      title: title,
      date: _date!,
      time: _timeController.text.trim().isEmpty ? null : _timeController.text.trim(),
      location:
          _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mail_outline, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.invitationReadDetails,
                  style: TextStyle(
                    color: AppColors.muted(context),
                    fontStyle: FontStyle.italic,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: l10n.coupleName,
            controller: _titleController,
            prefixIcon: Icons.favorite_outline,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: l10n.date,
            readOnly: true,
            onTap: _pickDate,
            prefixIcon: Icons.event_outlined,
            controller: _dateController,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: l10n.timeOptional,
            controller: _timeController,
            prefixIcon: Icons.schedule_outlined,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: l10n.locationOptional,
            controller: _locationController,
            prefixIcon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 16),
          CustomButton(
            label: l10n.addToUpcomingWeddings,
            icon: Icons.check,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
