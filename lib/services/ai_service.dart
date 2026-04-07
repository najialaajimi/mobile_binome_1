import 'dart:convert';
import 'dart:math';
import '../models/listing.dart';
import '../models/user_preferences.dart';
import 'storage_service.dart';
import 'auth_service.dart';
import 'listing_service.dart';

class AiService {
  static const _prefsKey = 'user_preferences_';
  static const _historyKey = 'view_history_';

  final StorageService _storage = StorageService.instance;
  final ListingService _listingService = ListingService();
  final AuthService _authService = AuthService();

  UserPreferences? getUserPreferences(String userId) {
    final raw = _storage.getString('$_prefsKey$userId');
    if (raw == null) return null;
    try {
      return UserPreferences.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUserPreferences(UserPreferences prefs) async {
    await _storage.setString(
        '$_prefsKey${prefs.userId}', jsonEncode(prefs.toJson()));
  }

  List<String> getViewHistory(String userId) {
    return _storage.getStringList('$_historyKey$userId') ?? [];
  }

  Future<void> addToViewHistory(String userId, String listingId) async {
    final history = getViewHistory(userId);
    if (!history.contains(listingId)) {
      history.insert(0, listingId);
      if (history.length > 50) history.removeLast();
      await _storage.setStringList('$_historyKey$userId', history);
    }
  }

  int getCompatibilityScore(UserPreferences prefs, Listing listing) {
    int score = 50;

    // Price match (25 pts)
    if (prefs.budgetMax != null && listing.price <= prefs.budgetMax!) {
      if (prefs.budgetMin != null && listing.price >= prefs.budgetMin!) {
        score += 25;
      } else {
        score += 15;
      }
    } else if (prefs.budgetMax != null &&
        listing.price > prefs.budgetMax! * 1.1) {
      score -= 20;
    }

    // Type match (20 pts)
    if (prefs.preferredTypes.isNotEmpty &&
        prefs.preferredTypes.contains(listing.type)) {
      score += 20;
    }

    // University proximity (20 pts)
    if (prefs.nearUniversity != 'any' && prefs.nearUniversity.isNotEmpty) {
      if (listing.nearbyUniversities.any((u) =>
          u.toLowerCase().contains(prefs.nearUniversity.toLowerCase()))) {
        score += 20;
      } else {
        score -= 10;
      }
    } else {
      score += 10;
    }

    // Target audience (15 pts)
    if (prefs.isStudent && listing.targetAudience.contains('étudiant')) {
      score += 15;
    } else if (!prefs.isStudent &&
        listing.targetAudience.contains('professionnel')) {
      score += 10;
    } else {
      score += 5;
    }

    // Furnished (10 pts)
    if (prefs.wantFurnished != null &&
        prefs.wantFurnished == listing.isFurnished) {
      score += 10;
    }

    // Surface/rooms (10 pts)
    if (prefs.minSurface != null && listing.surface >= prefs.minSurface!) {
      score += 5;
    }
    if (prefs.minRooms != null && listing.rooms >= prefs.minRooms!) {
      score += 5;
    }

    // Fraud penalty
    if (listing.fraudRisk == 'high') score -= 30;
    if (listing.fraudRisk == 'medium') score -= 10;

    // Review bonus
    if (listing.reviewScore >= 4.0) score += 5;

    return score.clamp(0, 100);
  }

  List<Listing> getRecommendations(String userId, {int limit = 10}) {
    final prefs = getUserPreferences(userId);
    final history = getViewHistory(userId);
    final allListings = _listingService.searchListings();

    final scored = allListings.map((l) {
      int score = prefs != null ? getCompatibilityScore(prefs, l) : 50;

      if (history.isNotEmpty) {
        final recentViews = history.take(5).toList();
        for (final id in recentViews) {
          final viewed = _listingService.getListingById(id);
          if (viewed != null && viewed.type == l.type) {
            score += 5;
          }
        }
      }

      if (l.views > 100) score += 5;
      if (l.views > 200) score += 5;
      score += (l.reviewScore * 3).round();
      if (history.contains(l.id)) score -= 15;

      return MapEntry(l, score);
    }).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.take(limit).map((e) => e.key).toList();
  }

  Map<String, dynamic> suggestPrice({
    required String city,
    required String type,
    required double surface,
    required int rooms,
    required bool isFurnished,
  }) {
    final Map<String, double> cityBasePricePerM2 = {
      'tunis': 12.0,
      'la marsa': 14.0,
      'sidi bou said': 16.0,
      'carthage': 15.0,
      'ariana': 10.0,
      'ben arous': 9.0,
      'la goulette': 11.0,
      'hammam lif': 9.0,
      'sousse': 9.0,
      'monastir': 8.5,
      'mahdia': 7.0,
      'sfax': 8.0,
      'gabes': 6.5,
      'nabeul': 8.0,
      'hammamet': 10.0,
      'bizerte': 7.5,
      'kairouan': 6.0,
      'gafsa': 5.5,
      'tozeur': 5.0,
    };

    final cityLower = city.toLowerCase().trim();
    double basePerM2 = 10.0;
    for (final entry in cityBasePricePerM2.entries) {
      if (cityLower.contains(entry.key) || entry.key.contains(cityLower)) {
        basePerM2 = entry.value;
        break;
      }
    }

    final Map<String, double> typeMultiplier = {
      'studio': 1.3,
      'room': 0.6,
      'colocation': 0.5,
      'apartment': 1.0,
      'house': 1.2,
    };
    final mult = typeMultiplier[type] ?? 1.0;
    final furnishedBonus = isFurnished ? 1.2 : 1.0;

    double estimated = surface * basePerM2 * mult * furnishedBonus;
    estimated = (estimated / 50).round() * 50.0;

    final minPrice = (estimated * 0.85).roundToDouble();
    final maxPrice = (estimated * 1.15).roundToDouble();

    return {
      'suggested': estimated,
      'min': minPrice,
      'max': maxPrice,
      'currency': 'TND/mois',
      'explanation':
          'Basé sur le marché de $city pour un(e) ${_typeLabel(type)} de ${surface.toInt()}m² (${isFurnished ? "meublé" : "non meublé"})',
    };
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'studio':
        return 'studio';
      case 'room':
        return 'chambre';
      case 'colocation':
        return 'colocation';
      case 'apartment':
        return 'appartement';
      case 'house':
        return 'maison';
      default:
        return type;
    }
  }

  Map<String, dynamic> detectFraud(Listing listing) {
    final reasons = <String>[];
    int riskScore = 0;

    final priceEstimate = suggestPrice(
      city: listing.city,
      type: listing.type,
      surface: listing.surface,
      rooms: listing.rooms,
      isFurnished: listing.isFurnished,
    );
    final suggested = priceEstimate['suggested'] as double;

    if (listing.price < suggested * 0.4) {
      riskScore += 40;
      reasons.add(
          'Prix anormalement bas (${listing.price.toInt()} TND vs ~${suggested.toInt()} TND estimé)');
    } else if (listing.price < suggested * 0.6) {
      riskScore += 20;
      reasons.add('Prix en dessous du marché');
    }

    final suspiciousKeywords = [
      'urgent',
      'partez à l\'étranger',
      'clés par courrier',
      'western union',
      'money gram',
      'moneygram',
      'transfert',
      'avance immédiate',
      'pas de visite',
      'sans visite',
      'confiance totale',
      'victime d\'arnaque',
      'pasteur',
      'missionnaire',
    ];

    final text = '${listing.title} ${listing.description}'.toLowerCase();
    for (final kw in suspiciousKeywords) {
      if (text.contains(kw)) {
        riskScore += 25;
        reasons.add('Expression suspecte détectée : "$kw"');
        break;
      }
    }

    if (listing.description.trim().length < 30) {
      riskScore += 15;
      reasons.add('Description trop courte');
    }

    if (listing.photos.isEmpty) {
      riskScore += 10;
      reasons.add('Aucune photo fournie');
    }

    if (listing.surface < 5 || listing.surface > 1000) {
      riskScore += 20;
      reasons.add(
          'Surface inhabituellement ${listing.surface < 5 ? "petite" : "grande"}');
    }

    if (listing.title.trim().length < 10) {
      riskScore += 10;
      reasons.add('Titre trop court');
    }

    String riskLevel;
    if (riskScore >= 40) {
      riskLevel = 'high';
    } else if (riskScore >= 20) {
      riskLevel = 'medium';
    } else {
      riskLevel = 'low';
    }

    return {
      'risk': riskLevel,
      'score': riskScore,
      'reasons': reasons,
    };
  }

  List<Map<String, dynamic>> findCompatibleRoommates(String userId) {
    final allUsers = _authService.getAllUsers();
    final myPrefs = getUserPreferences(userId);
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) return [];

    final results = <Map<String, dynamic>>[];

    for (final user in allUsers) {
      if (user.id == userId) continue;
      if (user.role != 'tenant') continue;

      final theirPrefs = getUserPreferences(user.id);
      if (theirPrefs == null) continue;
      if (!theirPrefs.preferredTypes.contains('colocation')) continue;

      int compatScore = 50;

      if (myPrefs != null && theirPrefs.lifestyle == myPrefs.lifestyle) {
        compatScore += 20;
      } else if (myPrefs?.lifestyle == 'any' ||
          theirPrefs.lifestyle == 'any') {
        compatScore += 10;
      }

      if (myPrefs != null &&
          myPrefs.budgetMax != null &&
          theirPrefs.budgetMax != null) {
        final overlap = min(myPrefs.budgetMax!, theirPrefs.budgetMax!) -
            max(myPrefs.budgetMin ?? 0, theirPrefs.budgetMin ?? 0);
        if (overlap > 0) compatScore += 15;
      }

      if (myPrefs != null &&
          (theirPrefs.preferredLanguage == myPrefs.preferredLanguage ||
              theirPrefs.preferredLanguage == 'any' ||
              myPrefs.preferredLanguage == 'any')) {
        compatScore += 10;
      }

      if (user.studyField != null &&
          currentUser.studyField != null &&
          user.studyField == currentUser.studyField) {
        compatScore += 5;
      }

      if (user.nationality != null &&
          currentUser.nationality != null &&
          user.nationality == currentUser.nationality) {
        compatScore += 5;
      }

      compatScore = compatScore.clamp(0, 100);

      results.add({
        'user': user,
        'score': compatScore,
        'preferences': theirPrefs,
      });
    }

    results.sort(
        (a, b) => (b['score'] as int).compareTo(a['score'] as int));
    return results;
  }
}
