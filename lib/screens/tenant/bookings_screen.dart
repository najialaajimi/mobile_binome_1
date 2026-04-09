import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/booking.dart';
import '../../services/booking_service.dart';
import '../../services/listing_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_state.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  final _bookingService = BookingService();
  final _listingService = ListingService();
  final _authService = AuthService();
  late TabController _tabController;

  List<Booking> _bookings = [];
  DateTime _calendarMonth =
      DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadBookings() {
    final userId = _authService.getCurrentUser()?.id ?? '';
    setState(() {
      _bookings = _bookingService.getBookingsByTenant(userId);
    });
  }

  List<Booking> _filterBookings(String status) {
    final now = DateTime.now();
    if (status == 'upcoming') {
      return _bookings
          .where((b) =>
              b.status != 'cancelled' && b.scheduledAt.isAfter(now))
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    } else if (status == 'past') {
      return _bookings
          .where((b) =>
              b.status != 'cancelled' && b.scheduledAt.isBefore(now))
          .toList()
        ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    } else {
      return _bookings.where((b) => b.status == 'cancelled').toList();
    }
  }

  String _monthName(int month) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Visites'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'Calendrier'),
            Tab(
                text:
                    'À venir (${_filterBookings('upcoming').length})'),
            Tab(text: 'Passées'),
            Tab(text: 'Annulées'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalendarView(),
          _buildBookingsList(_filterBookings('upcoming')),
          _buildBookingsList(_filterBookings('past')),
          _buildBookingsList(_filterBookings('cancelled')),
        ],
      ),
    );
  }

  // ── Calendar view ──────────────────────────────────────────────────

  Widget _buildCalendarView() {
    final year = _calendarMonth.year;
    final month = _calendarMonth.month;
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = firstDay.weekday % 7;
    final now = DateTime.now();

    final selectedDayBookings = _bookings
        .where((b) =>
            b.scheduledAt.year == _selectedDay.year &&
            b.scheduledAt.month == _selectedDay.month &&
            b.scheduledAt.day == _selectedDay.day &&
            b.status != 'cancelled')
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    return Column(
      children: [
        // Calendar header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
          child: Column(
            children: [
              // Month navigation
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => setState(() {
                      _calendarMonth =
                          DateTime(year, month - 1);
                    }),
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
                    onPressed: () => setState(() {
                      _calendarMonth =
                          DateTime(year, month + 1);
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['D', 'L', 'M', 'M', 'J', 'V', 'S']
                    .map((d) => SizedBox(
                          width: 36,
                          child: Text(d,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 4),
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
                      b.scheduledAt.day == day &&
                      b.status != 'cancelled');

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
                  itemBuilder: (_, i) => _BookingCard(
                    booking: selectedDayBookings[i],
                    listingTitle: _listingService
                            .getListingById(
                                selectedDayBookings[i].listingId)
                            ?.title ??
                        'Logement',
                    onCancel: selectedDayBookings[i]
                            .scheduledAt
                            .isAfter(DateTime.now())
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
    );
  }

  // ── List view ────────────────────────────────────────────────────

  Widget _buildBookingsList(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return const EmptyState(
        icon: Icons.calendar_today_outlined,
        title: 'Aucune visite',
        message: 'Vous n\'avez pas de visites dans cette catégorie.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (_, i) => _BookingCard(
        booking: bookings[i],
        listingTitle: _listingService
                .getListingById(bookings[i].listingId)
                ?.title ??
            'Logement',
        onCancel: bookings[i].scheduledAt.isAfter(DateTime.now())
            ? () async {
                await _bookingService.cancelBooking(bookings[i].id);
                _loadBookings();
              }
            : null,
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final String listingTitle;
  final VoidCallback? onCancel;

  const _BookingCard({
    required this.booking,
    required this.listingTitle,
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
    final dateFormat = DateFormat('dd MMMM yyyy', 'fr_FR');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    listingTitle,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.statusLabel,
                    style: TextStyle(
                        color: _statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  dateFormat.format(booking.scheduledAt),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time_outlined,
                    size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  timeFormat.format(booking.scheduledAt),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
            if (booking.status == 'confirmed') ...[
              const SizedBox(height: 14),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_2,
                        size: 40, color: AppColors.textPrimary),
                    Text('QR Code',
                        style: TextStyle(
                            fontSize: 9,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
            if (onCancel != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel_outlined,
                    size: 16, color: AppColors.error),
                label: const Text('Annuler la visite',
                    style: TextStyle(color: AppColors.error)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


