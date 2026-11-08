import 'package:flutter/material.dart';
import 'package:sukun/l10n/app_localizations.dart';
import 'package:sukun/utils/specialty_labels.dart';

import '../../main.dart';
import 'my_appointements_screen.dart';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({
    super.key,
    this.initialTherapistName = 'Dr. Leila Ahmed',
    this.initialSpecialty = 'Anxiety & Depression',
    this.initialDate = 'Today, Jan 9',
    this.initialTime = '2:00 PM',
    this.initialDuration = '1 hour',
    this.initialTotalPaid = '10 JD',
  });

  final String initialTherapistName;
  final String initialSpecialty;
  final String initialDate;
  final String initialTime;
  final String initialDuration;
  final String initialTotalPaid;

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  static const Color _backgroundColor = Color(0xFFF4EFEA);
  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _primaryGreen = Color(0xFF5E6F5C);
  static const Color _iconCircleColor = Color(0xFFC8D0C1);
  static const Color _textPrimary = Color(0xFF5F6E5B);
  static const Color _textSecondary = Color(0xFF8F9888);
  static const Color _textMuted = Color(0xFFB4B5AC);
  static const Color _dividerColor = Color(0xFFEFE7DE);

  late String _therapistName;
  late String _specialty;
  late String _date;
  late String _time;
  late String _duration;
  late String _totalPaid;

  @override
  void initState() {
    super.initState();
    _therapistName = widget.initialTherapistName;
    _specialty = widget.initialSpecialty;
    _date = widget.initialDate;
    _time = widget.initialTime;
    _duration = widget.initialDuration;
    _totalPaid = widget.initialTotalPaid;
  }

  void _handleGoToAppointments() {
    Navigator.of(context).pushNamed(
      AppRoutes.appointments,
      arguments: Appointment(
        id: '',
        therapistName: _therapistName,
        specialty: _specialty,
        date: _date,
        time: _time,
        price: _totalPaid,
        status: AppointmentStatus.upcoming,
        isNewlyBooked: true,
      ),
    );
  }

  num _rateFrom(String priceText) =>
      num.tryParse(priceText.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 56,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildSuccessIcon(),
                    const SizedBox(height: 28),
                    Text(
                      lang.bookingConfirmed,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      lang.sessionSuccessfullyBooked,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: FontWeight.w400,
                        color: _textSecondary,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildBookingDetailsCard(context),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _handleGoToAppointments,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: _primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Text(lang.goToMyAppointments),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        lang.confirmationEmailNote,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                          color: _textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 112,
      height: 112,
      decoration: const BoxDecoration(
        color: _iconCircleColor,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_circle_outline_rounded,
        size: 58,
        color: _primaryGreen,
      ),
    );
  }

  Widget _buildBookingDetailsCard(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _therapistName,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFFD0D1CC),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizedSpecialties(_specialty, lang),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFFDDD8D1),
            ),
          ),
          const SizedBox(height: 22),
          _DetailRow(
            label: lang.dateAndTime,
            value: '$_date | $_time',
          ),
          const SizedBox(height: 16),
          _DetailRow(
            label: lang.duration,
            value: _duration,
          ),
          const SizedBox(height: 16),
          const Divider(
            height: 1,
            thickness: 1,
            color: _dividerColor,
          ),
          const SizedBox(height: 16),
          _DetailRow(
            label: lang.totalPaid,
            value: lang.pricePerSession(_rateFrom(_totalPaid)),
            isMuted: true,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isMuted = false,
  });

  final String label;
  final String value;
  final bool isMuted;

  static const Color _labelColor = Color(0xFF9C9E98);
  static const Color _valueColor = Color(0xFF5B5F56);
  static const Color _mutedValueColor = Color(0xFFD0D1CB);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _labelColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isMuted ? _mutedValueColor : _valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
