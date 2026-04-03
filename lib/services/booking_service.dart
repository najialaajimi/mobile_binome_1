import 'dart:convert';
import '../models/booking.dart';
import 'storage_service.dart';

class BookingService {
  static const _bookingsKey = 'bookings';
  static const _seededKey = 'bookings_seeded';

  final StorageService _storage = StorageService.instance;

  Future<void> init() async {
    if (_storage.getBool(_seededKey) != true) {
      await _seedBookings();
      await _storage.setBool(_seededKey, true);
    }
  }

  Future<void> _seedBookings() async {
    final now = DateTime.now();
    final bookings = [
      Booking(
        id: 'booking_1',
        listingId: 'listing_1',
        tenantId: 'tenant_1',
        ownerId: 'owner_1',
        scheduledAt: now.add(const Duration(days: 3, hours: 10)),
        status: 'confirmed',
        qrCode: 'QR_BOOKING_1',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Booking(
        id: 'booking_2',
        listingId: 'listing_2',
        tenantId: 'tenant_1',
        ownerId: 'owner_1',
        scheduledAt: now.add(const Duration(days: 7, hours: 14)),
        status: 'pending',
        qrCode: 'QR_BOOKING_2',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Booking(
        id: 'booking_3',
        listingId: 'listing_3',
        tenantId: 'tenant_2',
        ownerId: 'owner_2',
        scheduledAt: now.subtract(const Duration(days: 5, hours: 9)),
        status: 'confirmed',
        qrCode: 'QR_BOOKING_3',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Booking(
        id: 'booking_4',
        listingId: 'listing_5',
        tenantId: 'tenant_2',
        ownerId: 'owner_2',
        scheduledAt: now.subtract(const Duration(days: 2)),
        status: 'cancelled',
        qrCode: 'QR_BOOKING_4',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
    ];
    final encoded = bookings.map((b) => jsonEncode(b.toJson())).toList();
    await _storage.setStringList(_bookingsKey, encoded);
  }

  List<Booking> _getAll() {
    final list = _storage.getStringList(_bookingsKey) ?? [];
    return list
        .map((s) => Booking.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveAll(List<Booking> bookings) async {
    final encoded = bookings.map((b) => jsonEncode(b.toJson())).toList();
    await _storage.setStringList(_bookingsKey, encoded);
  }

  List<Booking> getBookingsByTenant(String tenantId) =>
      _getAll().where((b) => b.tenantId == tenantId).toList();

  List<Booking> getBookingsByOwner(String ownerId) =>
      _getAll().where((b) => b.ownerId == ownerId).toList();

  Future<void> createBooking(Booking booking) async {
    final bookings = _getAll();
    bookings.add(booking);
    await _saveAll(bookings);
  }

  Future<bool> updateBookingStatus(String id, String status) async {
    final bookings = _getAll();
    final idx = bookings.indexWhere((b) => b.id == id);
    if (idx < 0) return false;
    bookings[idx] = bookings[idx].copyWith(status: status);
    await _saveAll(bookings);
    return true;
  }

  Future<bool> cancelBooking(String id) async =>
      updateBookingStatus(id, 'cancelled');
}
