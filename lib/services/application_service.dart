import 'dart:convert';
import '../models/application.dart';
import 'storage_service.dart';

class ApplicationService {
  static const _applicationsKey = 'applications';
  static const _seededKey = 'applications_seeded';

  final StorageService _storage = StorageService.instance;

  Future<void> init() async {
    if (_storage.getBool(_seededKey) != true) {
      await _seedApplications();
      await _storage.setBool(_seededKey, true);
    }
  }

  Future<void> _seedApplications() async {
    final now = DateTime.now();
    final apps = [
      RentalApplication(
        id: 'app_1',
        listingId: 'listing_1',
        tenantId: 'tenant_1',
        ownerId: 'owner_1',
        message: 'Bonjour, je suis intéressé par votre appartement. CDI, revenus stables, garant disponible.',
        desiredMoveIn: now.add(const Duration(days: 30)),
        status: 'pending',
        createdAt: now.subtract(const Duration(days: 3)),
        tenantBadges: ['CDI', 'Garant', 'Non-fumeur'],
      ),
      RentalApplication(
        id: 'app_2',
        listingId: 'listing_3',
        tenantId: 'tenant_2',
        ownerId: 'owner_2',
        message: 'Je suis une famille de 3 personnes, cherchons une maison pour s\'installer durablement.',
        desiredMoveIn: now.add(const Duration(days: 45)),
        status: 'accepted',
        createdAt: now.subtract(const Duration(days: 10)),
        tenantBadges: ['Famille', 'CDI', 'Garant'],
      ),
      RentalApplication(
        id: 'app_3',
        listingId: 'listing_2',
        tenantId: 'tenant_1',
        ownerId: 'owner_1',
        message: 'Étudiant en master, sérieux et discret. Bourse CROUS + aide parent.',
        desiredMoveIn: now.add(const Duration(days: 15)),
        status: 'rejected',
        createdAt: now.subtract(const Duration(days: 15)),
        tenantBadges: ['Étudiant', 'Boursier'],
      ),
    ];
    final encoded = apps.map((a) => jsonEncode(a.toJson())).toList();
    await _storage.setStringList(_applicationsKey, encoded);
  }

  List<RentalApplication> _getAll() {
    final list = _storage.getStringList(_applicationsKey) ?? [];
    return list
        .map((s) =>
            RentalApplication.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveAll(List<RentalApplication> apps) async {
    final encoded = apps.map((a) => jsonEncode(a.toJson())).toList();
    await _storage.setStringList(_applicationsKey, encoded);
  }

  List<RentalApplication> getApplicationsByTenant(String tenantId) =>
      _getAll().where((a) => a.tenantId == tenantId).toList();

  List<RentalApplication> getApplicationsByOwner(String ownerId) =>
      _getAll().where((a) => a.ownerId == ownerId).toList();

  Future<void> createApplication(RentalApplication application) async {
    final apps = _getAll();
    apps.add(application);
    await _saveAll(apps);
  }

  Future<bool> updateApplicationStatus(String id, String status) async {
    final apps = _getAll();
    final idx = apps.indexWhere((a) => a.id == id);
    if (idx < 0) return false;
    apps[idx] = apps[idx].copyWith(status: status);
    await _saveAll(apps);
    return true;
  }
}
