import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../services/booking_service.dart';
import '../../services/listing_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final _bookingService = BookingService();
  final _listingService = ListingService();
  final _authService = AuthService();
  DateTime _selectedDay = DateTime.now();
  DateTime _displayedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  List<Booking> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    final ownerId = _authService.getCurrentUser()?.id ?? '';
    setState(() {
      _bookings = _bookingService.getBookingsByOwner(ownerId);
    });
  }

  String _monthName(int month) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return months[month - 1];
  }

  void _prevMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = firstDay.weekday % 7;

    final selectedDayBookings = _bookings
        .where((b) =>
            b.scheduledAt.year == _selectedDay.year &&
            b.scheduledAt.month == _selectedDay.month &&
            b.scheduledAt.day == _selectedDay.day)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    return Scaffold(
      appBar: AppBar(title: const Text('Agenda des visites')),
      body: Column(
        children: [
          // Calendar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                // Month navigation
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _prevMonth,
                    ),
                    Expanded(
                      child: Text(
                        '${_monthName(month)} $year',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['D', 'L', 'M', 'M', 'J', 'V', 'S']
                      .map((d) => SizedBox(
                            width: 32,
                            child: Text(d,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 6),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 1,
                  ),
                  itemCount: firstWeekday + daysInMonth,
                  itemBuilder: (_, i) {
                    if (i < firstWeekday) return const SizedBox.shrink();
                    final day = i - firstWeekday + 1;
                    final date = DateTime(year, month, day);
                    final isSelected = _selectedDay.year == year &&
                        _selectedDay.month == month &&
                        _selectedDay.day == day;
                    final isToday = now.year == year &&
                        now.month == month &&
                        now.day == day;
                    final hasEvent = _bookings.any((b) =>
                        b.scheduledAt.year == year &&
                        b.scheduledAt.month == month &&
                        b.scheduledAt.day == day);

                    return GestureDetector(
                      onTap: () => setState(() => _selectedDay = date),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : isToday
                                  ? AppColors.primary.withAlpha(20)
                                  : null,
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                '$day',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : null,
                                  fontWeight: isToday || isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if (hasEvent && !isSelected)
                              Positioned(
                                bottom: 2,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                Text(
                  'Visites du ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                const Spacer(),
                Text(
                  '${selectedDayBookings.length} visite(s)',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Expanded(
            child: selectedDayBookings.isEmpty
                ? const Center(
                    child: Text('Aucune visite ce jour',
                        style:
                            TextStyle(color: AppColors.textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: selectedDayBookings.length,
                    itemBuilder: (_, i) =>
                        _AgendaCard(
                          booking: selectedDayBookings[i],
                          listingTitle: _listingService
                                  .getListingById(
                                      selectedDayBookings[i].listingId)
                                  ?.title ??
                              'Logement',
                          onConfirm:
                              selectedDayBookings[i].status == 'pending'
                                  ? () async {
                                      await _bookingService
                                          .updateBookingStatus(
                                              selectedDayBookings[i].id,
                                              'confirmed');
                                      _loadBookings();
                                    }
                                  : null,
                          onCancel:
                              selectedDayBookings[i].status != 'cancelled'
                                  ? () async {
                                      await _bookingService.cancelBooking(
                                          selectedDayBookings[i].id);
                                      _loadBookings();
                                    }
                                  : null,
                        ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AgendaCard extends StatelessWidget {
  final Booking booking;
  final String listingTitle;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const _AgendaCard({
    required this.booking,
    required this.listingTitle,
    this.onConfirm,
    this.onCancel,
  });

  Color get _statusColor {
    switch (booking.status) {
      case 'confirmed':
        return AppColors.success;
      case 'pending':
        return AppColors.secondary;
      case 'cancelled':
        return AppColors.textSecondary;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${booking.scheduledAt.hour.toString().padLeft(2, '0')}h${booking.scheduledAt.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    listingTitle,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.statusLabel,
                    style: TextStyle(
                        color: _statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (onConfirm != null || onCancel != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (onConfirm != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onConfirm,
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Confirmer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  if (onConfirm != null && onCancel != null)
                    const SizedBox(width: 8),
                  if (onCancel != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.cancel_outlined, size: 16),
                        label: const Text('Annuler'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding:
                              const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}


