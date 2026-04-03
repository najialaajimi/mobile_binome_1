import 'package:flutter/material.dart';
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

  String _monthName(int month) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final ownerId = _authService.getCurrentUser()?.id ?? '';
    final bookings = _bookingService.getBookingsByOwner(ownerId);
    final todayBookings = bookings
        .where((b) =>
            b.scheduledAt.year == _selectedDay.year &&
            b.scheduledAt.month == _selectedDay.month &&
            b.scheduledAt.day == _selectedDay.day)
        .toList();

    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstWeekday = firstDay.weekday % 7;

    return Scaffold(
      appBar: AppBar(title: const Text('Agenda')),
      body: Column(
        children: [
          // Calendar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_monthName(now.month)} ${now.year}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['D', 'L', 'M', 'M', 'J', 'V', 'S']
                      .map((d) => Text(d,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppColors.textSecondary)))
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
                  ),
                  itemCount: firstWeekday + daysInMonth,
                  itemBuilder: (_, i) {
                    if (i < firstWeekday) return const SizedBox.shrink();
                    final day = i - firstWeekday + 1;
                    final date = DateTime(now.year, now.month, day);
                    final isSelected = _selectedDay.day == day &&
                        _selectedDay.month == now.month &&
                        _selectedDay.year == now.year;
                    final isToday = now.day == day;
                    final hasEvent = bookings.any((b) =>
                        b.scheduledAt.year == now.year &&
                        b.scheduledAt.month == now.month &&
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
                                  color: isSelected
                                      ? Colors.white
                                      : null,
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
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Text(
                  'Visites du ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          Expanded(
            child: todayBookings.isEmpty
                ? const Center(
                    child: Text('Aucune visite ce jour',
                        style: TextStyle(
                            color: AppColors.textSecondary)))
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: todayBookings.length,
                    itemBuilder: (_, i) {
                      final b = todayBookings[i];
                      final listing =
                          _listingService.getListingById(b.listingId);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const Icon(
                              Icons.calendar_today_outlined,
                              color: AppColors.primary),
                          title: Text(listing?.title ?? 'Visite',
                              style: const TextStyle(fontSize: 14)),
                          subtitle: Text(
                              '${b.scheduledAt.hour.toString().padLeft(2, '0')}h${b.scheduledAt.minute.toString().padLeft(2, '0')} - ${b.statusLabel}'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
