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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          .toList();
    } else if (status == 'past') {
      return _bookings
          .where((b) =>
              b.status != 'cancelled' && b.scheduledAt.isBefore(now))
          .toList();
    } else {
      return _bookings.where((b) => b.status == 'cancelled').toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Visites'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'À venir'),
            Tab(text: 'Passées'),
            Tab(text: 'Annulées'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsList(_filterBookings('upcoming')),
          _buildBookingsList(_filterBookings('past')),
          _buildBookingsList(_filterBookings('cancelled')),
        ],
      ),
    );
  }

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              // QR Code placeholder
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
