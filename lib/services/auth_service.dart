import 'dart:convert';
import '../models/user.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class AuthService {
  static const _usersKey = 'users';
  static const _currentUserKey = 'current_user';
  static const _seededKey = 'auth_seeded_v2';

  final StorageService _storage = StorageService.instance;

  Future<void> init() async {
    if (_storage.getBool(_seededKey) != true) {
      await _seedUsers();
      await _storage.setBool(_seededKey, true);
    }
  }

  String _hashPassword(String password) =>
      base64Encode(utf8.encode(password));

  Future<void> _seedUsers() async {
    final users = [
      AppUser(
        id: 'admin_1',
        fullName: 'Administrateur',
        email: 'admin@logement.com',
        password: _hashPassword('admin123'),
        role: AppConstants.roleAdmin,
        isVerified: true,
        nationality: 'Tunisien',
        preferredLanguage: 'fr',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      AppUser(
        id: 'owner_1',
        fullName: 'Karim Mansour',
        email: 'proprietaire@test.com',
        password: _hashPassword('test123'),
        role: AppConstants.roleOwner,
        isVerified: true,
        nationality: 'Tunisien',
        preferredLanguage: 'fr',
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
      ),
      AppUser(
        id: 'owner_2',
        fullName: 'Leila Ben Salah',
        email: 'marie@test.com',
        password: _hashPassword('test123'),
        role: AppConstants.roleOwner,
        isVerified: false,
        nationality: 'Tunisienne',
        preferredLanguage: 'ar',
        createdAt: DateTime.now().subtract(const Duration(days: 100)),
      ),
      AppUser(
        id: 'tenant_1',
        fullName: 'Ahmed Trabelsi',
        email: 'locataire@test.com',
        password: _hashPassword('test123'),
        role: AppConstants.roleTenant,
        isVerified: true,
        nationality: 'Tunisien',
        isStudent: true,
        studyField: 'informatique',
        preferredLanguage: 'fr',
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
      ),
      AppUser(
        id: 'tenant_2',
        fullName: 'Fatma Khelifa',
        email: 'sophie@test.com',
        password: _hashPassword('test123'),
        role: AppConstants.roleTenant,
        isVerified: false,
        nationality: 'Tunisienne',
        isStudent: true,
        studyField: 'médecine',
        preferredLanguage: 'fr',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      AppUser(
        id: 'tenant_3',
        fullName: 'Ibrahim Koné',
        email: 'ibrahim@test.com',
        password: _hashPassword('test123'),
        role: AppConstants.roleTenant,
        isVerified: true,
        nationality: 'Sénégalais',
        isStudent: true,
        studyField: 'ingénierie',
        preferredLanguage: 'fr',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      AppUser(
        id: 'tenant_4',
        fullName: 'Marie Nguyen',
        email: 'nguyen@test.com',
        password: _hashPassword('test123'),
        role: AppConstants.roleTenant,
        isVerified: false,
        nationality: 'Française',
        isStudent: false,
        preferredLanguage: 'fr',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];
    final encoded = users.map((u) => jsonEncode(u.toJson())).toList();
    await _storage.setStringList(_usersKey, encoded);
  }
  List<AppUser> _getUsers() {
    final list = _storage.getStringList(_usersKey) ?? [];
    return list
        .map((s) => AppUser.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveUsers(List<AppUser> users) async {
    final encoded = users.map((u) => jsonEncode(u.toJson())).toList();
    await _storage.setStringList(_usersKey, encoded);
  }

  Future<AppUser?> signIn(String email, String password) async {
    final users = _getUsers();
    final hashed = _hashPassword(password);
    try {
      final user = users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase() && u.password == hashed,
      );
      await _storage.setString(_currentUserKey, jsonEncode(user.toJson()));
      return user;
    } catch (_) {
      return null;
    }
  }

  Future<AppUser?> signUp(
      String fullName, String email, String password, String role) async {
    final users = _getUsers();
    final exists = users.any(
        (u) => u.email.toLowerCase() == email.toLowerCase());
    if (exists) return null;

    final effectiveRole =
        email.toLowerCase() == 'admin@logement.com' ? AppConstants.roleAdmin : role;

    final newUser = AppUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      email: email,
      password: _hashPassword(password),
      role: effectiveRole,
      isVerified: false,
      createdAt: DateTime.now(),
    );
    users.add(newUser);
    await _saveUsers(users);
    await _storage.setString(_currentUserKey, jsonEncode(newUser.toJson()));
    return newUser;
  }

  Future<void> signOut() async {
    await _storage.remove(_currentUserKey);
  }

  AppUser? getCurrentUser() {
    final raw = _storage.getString(_currentUserKey);
    if (raw == null) return null;
    try {
      return AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  bool isLoggedIn() => getCurrentUser() != null;

  Future<bool> updateUser(AppUser user) async {
    final users = _getUsers();
    final idx = users.indexWhere((u) => u.id == user.id);
    if (idx < 0) return false;
    users[idx] = user;
    await _saveUsers(users);
    await _storage.setString(_currentUserKey, jsonEncode(user.toJson()));
    return true;
  }

  List<AppUser> getAllUsers() => _getUsers();

  Future<bool> deleteUser(String userId) async {
    final users = _getUsers();
    final updated = users.where((u) => u.id != userId).toList();
    if (updated.length == users.length) return false;
    await _saveUsers(updated);
    return true;
  }
}
