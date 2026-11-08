import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sukun/l10n/app_localizations.dart';
import 'package:sukun/services/push_notification_service.dart';
import 'package:sukun/utils/error_handler.dart';
import 'package:sukun/utils/perf.dart';
import 'package:sukun/utils/specialty_labels.dart';

import '../../main.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    this.therapistName = 'Dr. Leila Ahmed',
    this.therapistSpecialty = 'Anxiety & Depression',
    this.sessionPrice = '10 JD',
    this.sessionDate = 'Today, Jan 9',
    this.sessionTime = '2:00 PM',
    this.sessionDuration = '1 hour',
    this.totalPrice = '10 JD',
    this.therapistId = '',
    this.slotId = '',
    this.initialPaymentMethod = 'Credit Card',
  });

  final String therapistName;
  final String therapistSpecialty;
  final String sessionPrice;
  final String sessionDate;
  final String sessionTime;
  final String sessionDuration;
  final String totalPrice;
  final String therapistId;
  final String slotId;
  final String initialPaymentMethod;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const Color _backgroundColor = Color(0xFFF4EFEA);
  static const Color _primaryGreen = Color(0xFF6B7E67);
  static const Color _softGreen = Color(0xFFC7CEBF);
  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _dividerColor = Color(0xFFE5DDD3);
  static const Color _textPrimary = Color(0xFF4D514A);
  static const Color _textSecondary = Color(0xFF8B8E86);
  static const Color _textMuted = Color(0xFFA8AAA3);

  late final TextEditingController _cardNumberController;
  late final TextEditingController _expiryController;
  late final TextEditingController _cvvController;

  late String _selectedPaymentMethod;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = widget.initialPaymentMethod;
    _cardNumberController = TextEditingController();
    _expiryController = TextEditingController();
    _cvvController = TextEditingController();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _selectPaymentMethod(String method) {
    setState(() {
      _selectedPaymentMethod = method;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Converts "HH:MM", "HH:MM:SS", or "H:MM AM/PM" to total minutes since midnight.
  int _parseTimeToMinutes(String time) {
    try {
      final upper = time.toUpperCase();
      final colonParts = time.split(':');
      int hours = int.parse(colonParts[0].trim());
      int minutes = int.parse(colonParts[1].trim().split(' ')[0]);
      if (upper.contains('PM') && hours != 12) hours += 12;
      if (upper.contains('AM') && hours == 12) hours = 0;
      return hours * 60 + minutes;
    } catch (_) {
      return 0;
    }
  }

  bool _isPaymentValid(AppLocalizations lang) {
    if (_selectedPaymentMethod == 'Credit Card') {
      final cardNumber = _cardNumberController.text.replaceAll(' ', '');
      final expiry = _expiryController.text.trim();
      final cvv = _cvvController.text.trim();

      if (cardNumber.length != 16) {
        _showMessage(lang.invalidCardNumber);
        return false;
      }

      if (expiry.length != 5 || !expiry.contains('/')) {
        _showMessage(lang.invalidExpiryDate);
        return false;
      }

      if (cvv.length != 3) {
        _showMessage(lang.invalidCvv);
        return false;
      }
    }

    return true;
  }

  Future<void> _handleConfirmPayment() async {
    final lang = AppLocalizations.of(context)!;
    if (!_isPaymentValid(lang)) return;

    final cardNumber = _cardNumberController.text.replaceAll(' ', '');
    if (cardNumber != '4242424242424242') {
      _showMessage(lang.paymentFailedTestCard);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final patientId = supabase.auth.currentUser!.id;

      // Double-booking guard: therapist can't have two sessions within 60 min.
      final dateStr = widget.sessionDate.contains('-')
          ? widget.sessionDate
          : DateTime.now().toIso8601String().substring(0, 10);

      final existing = await supabase
          .from('appointments')
          .select('scheduled_time')
          .eq('therapist_id', widget.therapistId)
          .eq('scheduled_date', dateStr)
          .inFilter('status', ['pending', 'confirmed']);

      final newMins = _parseTimeToMinutes(widget.sessionTime);
      for (final appt in existing) {
        final existingMins = _parseTimeToMinutes(appt['scheduled_time'] as String? ?? '');
        if ((newMins - existingMins).abs() < 60) {
          setState(() => _isLoading = false);
          _showMessage('This time slot is unavailable — the therapist already has a session within the hour.');
          return;
        }
      }

      final priceStr = widget.totalPrice.replaceAll(RegExp(r'[^0-9.]'), '');
      final price = double.tryParse(priceStr) ?? 0;

      final meetingId = 'sukun-${DateTime.now().millisecondsSinceEpoch}';
      final meetingUrl = 'https://meet.jit.si/$meetingId';

      final appointment = await timeAsync('booking_payment_write', () async {
        final appointment = await supabase
            .from('appointments')
            .insert({
              'patient_id': patientId,
              'therapist_id': widget.therapistId,
              'scheduled_date': widget.sessionDate.contains('-')
                  ? widget.sessionDate
                  : DateTime.now().toIso8601String().substring(0, 10),
              'scheduled_time': widget.sessionTime,
              'duration_minutes': 60,
              'status': 'pending',
              'price': price,
              'meeting_url': meetingUrl,
            })
            .select()
            .single();

        await supabase.from('payments').insert({
          'appointment_id': appointment['id'],
          'patient_id': patientId,
          'amount': price,
          'status': 'completed',
        });

        return appointment;
      });

      if (widget.slotId.isNotEmpty) {
        await supabase
            .from('availability_slots')
            .update({'status': 'blocked'})
            .eq('id', widget.slotId);
      }

      // Notify the therapist of the new booking request.
      // Wrapped separately so a notification failure never breaks the booking.
      try {
        await supabase.from('notifications').insert({
          'user_id': widget.therapistId,
          'title': 'New booking request',
          'body': 'You have a new session request on ${widget.sessionDate} at ${widget.sessionTime}.',
          'type': 'booking_request',
        });
      } catch (e) {
        debugPrint('Notification insert failed (non-blocking): $e');
      }

      // Also send a push notification to the therapist (non-blocking).
      await PushNotificationService.sendPushToUser(
        userId: widget.therapistId,
        title: 'New booking request',
        body: 'You have a new session request on ${widget.sessionDate} at ${widget.sessionTime}.',
      );

      if (!mounted) return;
      Navigator.of(context).pushNamed(
        AppRoutes.bookingConfirmation,
        arguments: {
          'therapistName': widget.therapistName,
          'therapistSpecialty': widget.therapistSpecialty,
          'sessionDate': widget.sessionDate,
          'sessionTime': widget.sessionTime,
          'sessionDuration': widget.sessionDuration,
          'totalPrice': widget.totalPrice,
          'meetingUrl': meetingUrl,
          'appointmentId': appointment['id'],
        },
      );
    } catch (e) {
      _showMessage(friendlyError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  num _rateFrom(String priceText) =>
      num.tryParse(priceText.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          size: 20,
                          color: _textPrimary,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    Center(
                      child: Text(
                        lang.checkout,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                color: _dividerColor,
              ),
              const SizedBox(height: 24),
              _buildTherapistCard(),
              const SizedBox(height: 18),
              Text(
                lang.sessionDetails,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _buildSessionDetailsCard(lang),
              const SizedBox(height: 18),
              Text(
                lang.paymentMethod,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _PaymentMethodButton(
                label: lang.creditCard,
                icon: Icons.credit_card_rounded,
                isSelected: _selectedPaymentMethod == 'Credit Card',
                onTap: () => _selectPaymentMethod('Credit Card'),
              ),
              const SizedBox(height: 14),
              _buildPaymentFieldsCard(lang),
              const SizedBox(height: 14),
              _buildTotalCard(lang),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleConfirmPayment,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(lang.confirmPayment),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  lang.paymentsSecureEncrypted,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: _textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTherapistCard() {
    final lang = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: _softGreen,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.therapistName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  localizedSpecialties(widget.therapistSpecialty, lang),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            lang.pricePerSession(_rateFrom(widget.sessionPrice)),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionDetailsCard(AppLocalizations lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          _SessionDetailRow(label: lang.date, value: widget.sessionDate),
          const SizedBox(height: 12),
          _SessionDetailRow(label: lang.time, value: widget.sessionTime),
          const SizedBox(height: 12),
          _SessionDetailRow(label: lang.duration, value: widget.sessionDuration),
        ],
      ),
    );
  }

  Widget _buildPaymentFieldsCard(AppLocalizations lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardInputField(
            label: lang.cardNumber,
            hintText: '1234 5678 9012 3456',
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CardNumberFormatter(),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _CardInputField(
                  label: lang.expiryDate,
                  hintText: 'MM/YY',
                  controller: _expiryController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ExpiryDateFormatter(),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CardInputField(
                  label: lang.cvv,
                  hintText: '123',
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(AppLocalizations lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: _softGreen,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Text(
            lang.total,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            lang.pricePerSession(_rateFrom(widget.totalPrice)),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionDetailRow extends StatelessWidget {
  const _SessionDetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  static const Color _textPrimary = Color(0xFF4D514A);
  static const Color _textSecondary = Color(0xFF9A9D95);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _textSecondary,
            ),
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodButton extends StatelessWidget {
  const _PaymentMethodButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color _primaryGreen = Color(0xFF6B7E67);
  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _borderColor = Color(0xFFD7D0C7);
  static const Color _selectedText = Color(0xFFFFFFFF);
  static const Color _defaultText = Color(0xFF5F635B);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? _primaryGreen : _cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? _primaryGreen : _borderColor,
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? _selectedText : _defaultText,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? _selectedText : _defaultText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardInputField extends StatelessWidget {
  const _CardInputField({
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;

  static const Color _fieldFill = Color(0xFFF4EEE6);
  static const Color _fieldBorder = Color(0xFFD8CCBE);
  static const Color _focusedBorder = Color(0xFF6B7E67);
  static const Color _textPrimary = Color(0xFF4D514A);
  static const Color _textSecondary = Color(0xFF8B8E86);
  static const Color _hintColor = Color(0xFFB7AA9A);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 46,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            obscureText: obscureText,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: _hintColor,
              ),
              filled: true,
              fillColor: _fieldFill,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: _fieldBorder,
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: _fieldBorder,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: _focusedBorder,
                  width: 1.3,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final truncated = digitsOnly.length > 16 ? digitsOnly.substring(0, 16) : digitsOnly;
    final buffer = StringBuffer();

    for (var index = 0; index < truncated.length; index++) {
      if (index > 0 && index % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(truncated[index]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final truncated = digitsOnly.length > 4 ? digitsOnly.substring(0, 4) : digitsOnly;
    final buffer = StringBuffer();

    for (var index = 0; index < truncated.length; index++) {
      if (index == 2) {
        buffer.write('/');
      }
      buffer.write(truncated[index]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
