import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart' show Color;
import '../models/listing.dart';
import '../models/user_preferences.dart';
import 'storage_service.dart';
import 'auth_service.dart';
import 'listing_service.dart';

// ─────────────────────────────────────────────
// Result types for AI analyses
// ─────────────────────────────────────────────

class PhotoAuthenticityResult {
  /// 'authentic', 'suspicious', 'high_risk'
  final String verdict;
  final int riskScore; // 0-100
  final List<String> signals;
  final List<String> recommendations;

  const PhotoAuthenticityResult({
    required this.verdict,
    required this.riskScore,
    required this.signals,
    required this.recommendations,
  });

  Color get verdictColor {
    switch (verdict) {
      case 'authentic':
        return const Color(0xFF388E3C);
      case 'suspicious':
        return const Color(0xFFFFA000);
      default:
        return const Color(0xFFD32F2F);
    }
  }

  String get verdictLabel {
    switch (verdict) {
      case 'authentic':
        return 'Photo authentique';
      case 'suspicious':
        return 'Photo suspecte';
      default:
        return 'Risque élevé (GAN probable)';
    }
  }

  String get verdictIcon {
    switch (verdict) {
      case 'authentic':
        return '✅';
      case 'suspicious':
        return '⚠️';
      default:
        return '🚫';
    }
  }
}

class PhotoQualityResult {
  final int qualityScore; // 0-100
  final List<String> issues;
  final List<String> tips;

  const PhotoQualityResult({
    required this.qualityScore,
    required this.issues,
    required this.tips,
  });
}

class TextFraudAnalysis {
  final int overallScore; // 0-100 (higher = more suspicious)
  final String riskLevel; // 'low', 'medium', 'high'
  final List<_TextSignal> signals;

  const TextFraudAnalysis({
    required this.overallScore,
    required this.riskLevel,
    required this.signals,
  });
}

class _TextSignal {
  final String category;
  final String description;
  final int weight; // contribution to score
  final bool isPositive; // true = good signal, false = bad signal

  const _TextSignal({
    required this.category,
    required this.description,
    required this.weight,
    required this.isPositive,
  });
}

// ─────────────────────────────────────────────
// AiService
// ─────────────────────────────────────────────

class AiService {
  static const _prefsKey = 'user_preferences_';
  static const _historyKey = 'view_history_';

  final StorageService _storage = StorageService.instance;
  final ListingService _listingService = ListingService();
  final AuthService _authService = AuthService();

  // ── Preferences ────────────────────────────

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

  // ── View history ───────────────────────────

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

  // ── Compatibility score ────────────────────

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

  // ── Smart recommendations ──────────────────

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

  // ── Price suggestion ───────────────────────

  Map<String, dynamic> suggestPrice({
    required String city,
    required String type,
    required double surface,
    required int rooms,
    required bool isFurnished,
  }) {
    // Keys are lowercase for matching against `cityLower` (user input normalized
    // via .toLowerCase().trim()). The bidirectional contains() check handles
    // variants like "Tunis", "TUNIS", "Lac de Tunis", "La Marsa", etc.
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

  // ── Legacy detectFraud (used in create listing) ──

  Map<String, dynamic> detectFraud(Listing listing) {
    final analysis = analyzeTextFraud(listing.title, listing.description);
    final reasons = analysis.signals
        .where((s) => !s.isPositive)
        .map((s) => s.description)
        .toList();

    // Price check
    final priceEstimate = suggestPrice(
      city: listing.city,
      type: listing.type,
      surface: listing.surface,
      rooms: listing.rooms,
      isFurnished: listing.isFurnished,
    );
    final suggested = priceEstimate['suggested'] as double;
    if (listing.price < suggested * 0.4) {
      reasons.insert(0,
          'Prix anormalement bas (${listing.price.toInt()} TND vs ~${suggested.toInt()} TND estimé)');
    } else if (listing.price < suggested * 0.6) {
      reasons.insert(0, 'Prix en dessous du marché');
    }

    // Photos check
    if (listing.photos.isEmpty) {
      reasons.add('Aucune photo fournie');
    }

    return {
      'risk': analysis.riskLevel,
      'score': analysis.overallScore,
      'reasons': reasons,
    };
  }

  // ── Detailed text fraud analysis ─────────────────────────────────────────

  /// Analyzes listing title + description for fraud indicators.
  /// Returns a structured [TextFraudAnalysis] with per-signal breakdown.
  TextFraudAnalysis analyzeTextFraud(String title, String description) {
    final signals = <_TextSignal>[];
    final text = '$title $description';
    // Normalize spaces so 'money gram' and 'moneygram' both match 'moneygram'
    final textLower = text.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    final textNormalized = textLower.replaceAll(' ', '');

    // 1. Suspicious payment/scam keywords
    const scamKeywords = [
      'western union',
      'moneygram',
      'transfert bancaire',
      'virement immédiat',
      'clés par courrier',
      'clef par courrier',
      'pasteur',
      'missionnaire',
      'victime',
      'arnaque précédente',
      'partez à l\'étranger',
      'je suis à l\'étranger',
      'en déplacement',
      'pas de visite possible',
      'sans visite',
    ];
    // Check against both normalized and regular text to catch spaced variants
    final foundScam = scamKeywords
        .where((kw) =>
            textLower.contains(kw) ||
            textNormalized.contains(kw.replaceAll(' ', '')))
        .toList();
    if (foundScam.isNotEmpty) {
      signals.add(_TextSignal(
        category: 'Mots-clés d\'arnaque',
        description:
            'Expressions suspectes détectées : ${foundScam.take(3).map((k) => '"$k"').join(', ')}',
        weight: 35,
        isPositive: false,
      ));
    }

    // 2. Urgency/pressure language
    const urgencyKeywords = [
      'urgent',
      'urgente',
      'immédiatement',
      'immédiat',
      'rapidement',
      'vite',
      'offre limitée',
      'dernière chance',
      'ne ratez pas',
    ];
    final foundUrgency =
        urgencyKeywords.where((kw) => textLower.contains(kw)).toList();
    if (foundUrgency.isNotEmpty) {
      signals.add(_TextSignal(
        category: 'Langage d\'urgence',
        description:
            'Pression psychologique détectée : ${foundUrgency.take(2).map((k) => '"$k"').join(', ')}',
        weight: 20,
        isPositive: false,
      ));
    }

    // 3. Contact info in description (phone / email)
    final phonePattern = RegExp(r'(\+?[\d\s\-\(\)]{8,})', multiLine: true);
    final emailPattern =
        RegExp(r'[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}');
    final hasPhone = phonePattern.hasMatch(description);
    final hasEmail = emailPattern.hasMatch(description);
    if (hasPhone || hasEmail) {
      signals.add(_TextSignal(
        category: 'Coordonnées dans la description',
        description:
            'Coordonnées personnelles détectées (${[if (hasPhone) 'téléphone', if (hasEmail) 'email'].join(', ')}). Communiquez via la messagerie de la plateforme.',
        weight: 25,
        isPositive: false,
      ));
    }

    // 4. Excessive uppercase (shouting / spam)
    final upperCount =
        text.runes.where((r) => r >= 65 && r <= 90).length; // A-Z
    final totalLetters =
        text.runes.where((r) => (r >= 65 && r <= 90) || (r >= 97 && r <= 122))
            .length;
    if (totalLetters > 20 && upperCount / totalLetters > 0.4) {
      signals.add(_TextSignal(
        category: 'Abus de majuscules',
        description:
            'Trop de majuscules (${(upperCount / totalLetters * 100).toInt()}%). Ce style est associé au spam.',
        weight: 15,
        isPositive: false,
      ));
    }

    // 5. Excessive punctuation
    final excessivePunctPattern = RegExp(r'[!?]{2,}');
    if (excessivePunctPattern.hasMatch(text)) {
      signals.add(_TextSignal(
        category: 'Ponctuation excessive',
        description:
            'Utilisation excessive de "!!" ou "??" — signe de manipulation émotionnelle.',
        weight: 10,
        isPositive: false,
      ));
    }

    // 6. Description too short
    if (description.trim().length < 30) {
      signals.add(_TextSignal(
        category: 'Description insuffisante',
        description:
            'Description trop courte (${description.trim().length} caractères). Une annonce sérieuse décrit le logement en détail.',
        weight: 15,
        isPositive: false,
      ));
    } else if (description.trim().length > 150) {
      signals.add(_TextSignal(
        category: 'Description détaillée',
        description: 'Description complète et détaillée — bon signe.',
        weight: 10,
        isPositive: true,
      ));
    }

    // 7. Title too short
    if (title.trim().length < 10) {
      signals.add(_TextSignal(
        category: 'Titre trop court',
        description: 'Titre insuffisant (${title.trim().length} caractères).',
        weight: 10,
        isPositive: false,
      ));
    }

    // 8. Positive: mentions location / reference points
    final locationKeywords = [
      'métro',
      'bus',
      'université',
      'fac',
      'campus',
      'école',
      'centre-ville',
      'rue',
      'avenue',
      'boulevard',
      'quartier',
    ];
    if (locationKeywords.any((kw) => textLower.contains(kw))) {
      signals.add(_TextSignal(
        category: 'Repères géographiques',
        description: 'L\'annonce mentionne des repères de localisation.',
        weight: 5,
        isPositive: true,
      ));
    }

    // 9. Positive: price/charges mention
    if (textLower.contains('charge') ||
        textLower.contains('tnd') ||
        textLower.contains('dt') ||
        textLower.contains('dinar')) {
      signals.add(_TextSignal(
        category: 'Transparence sur les charges',
        description: 'Les charges ou le prix sont mentionnés dans la description.',
        weight: 5,
        isPositive: true,
      ));
    }

    // Compute score
    int score = 0;
    for (final s in signals) {
      if (!s.isPositive) {
        score += s.weight;
      }
    }
    score = score.clamp(0, 100);

    String riskLevel;
    if (score >= 40) {
      riskLevel = 'high';
    } else if (score >= 20) {
      riskLevel = 'medium';
    } else {
      riskLevel = 'low';
    }

    return TextFraudAnalysis(
      overallScore: score,
      riskLevel: riskLevel,
      signals: signals,
    );
  }

  // ── Photo authenticity (GAN detection simulation) ────────────────────────

  /// Simulates GAN/deepfake detection on a photo URL using heuristic rules.
  /// In a real app this would call an ML model endpoint.
  PhotoAuthenticityResult analyzePhotoAuthenticity(String photoUrl) {
    final signals = <String>[];
    final recommendations = <String>[];
    int riskScore = 0;

    final urlLower = photoUrl.toLowerCase().trim();

    // 1. Stock photo / placeholder sites
    const stockSites = [
      'unsplash.com',
      'pexels.com',
      'pixabay.com',
      'shutterstock.com',
      'gettyimages.com',
      'istockphoto.com',
      'freepik.com',
      'loremflickr.com',
      'picsum.photos',
      'placeholder.com',
      'placehold.it',
      'via.placeholder',
      'dummyimage.com',
    ];
    if (stockSites.any((s) => urlLower.contains(s))) {
      riskScore += 50;
      signals.add('Photo provenant d\'un site de banque d\'images — risque de photo générique non représentative du bien.');
      recommendations.add('Prenez des photos originales du logement avec votre propre appareil.');
    }

    // 2. URL contains common GAN/AI image generator patterns
    const aiGeneratorPatterns = [
      'midjourney',
      'stable-diffusion',
      'dall-e',
      'dalle',
      'generated',
      'ai-generated',
      'thispersondoesnotexist',
      'thisrentaldoesnotexist',
      'deepai',
      'craiyon',
      'nightcafe',
    ];
    if (aiGeneratorPatterns.any((p) => urlLower.contains(p))) {
      riskScore += 70;
      signals.add('URL associée à un générateur d\'images IA (GAN/Diffusion) — photo probablement générée artificiellement.');
      recommendations.add('Les photos générées par IA sont interdites. Utilisez uniquement des photos réelles du logement.');
    }

    // 3. No extension or suspicious extension
    final hasImageExt = RegExp(r'\.(jpg|jpeg|png|webp|gif|bmp|avif)(\?|$)',
            caseSensitive: false)
        .hasMatch(urlLower);
    if (!hasImageExt) {
      riskScore += 20;
      signals.add('Format d\'image non standard ou URL sans extension reconnue.');
      recommendations.add('Utilisez des photos aux formats standards : JPG, PNG ou WebP.');
    }

    // 4. URL too short / clearly fake
    if (photoUrl.trim().length < 15) {
      riskScore += 30;
      signals.add('URL trop courte — probable lien invalide ou fictif.');
      recommendations.add('Vérifiez que le lien pointe vers une vraie photo accessible en ligne.');
    }

    // 5. URL does not start with http(s)
    if (!urlLower.startsWith('http://') && !urlLower.startsWith('https://')) {
      riskScore += 25;
      signals.add('L\'URL ne commence pas par https:// — lien potentiellement invalide.');
      recommendations.add('Utilisez uniquement des liens HTTPS sécurisés.');
    } else if (urlLower.startsWith('http://')) {
      riskScore += 5;
      signals.add('Connexion non sécurisée (HTTP). Préférez HTTPS.');
      recommendations.add('Hébergez vos photos sur un serveur HTTPS.');
    }

    // 6. Positive: known hosting platforms (trusted)
    const trustedHosts = [
      'imgur.com',
      'cloudinary.com',
      'res.cloudinary.com',
      'storage.googleapis.com',
      'amazonaws.com',
      's3.amazonaws.com',
      'firebasestorage.googleapis.com',
      'cdn.',
      'images.',
    ];
    final isTrusted = trustedHosts.any((h) => urlLower.contains(h));
    if (isTrusted) {
      riskScore = (riskScore - 15).clamp(0, 100);
      signals.add('Photo hébergée sur une plateforme de confiance.');
    }

    riskScore = riskScore.clamp(0, 100);

    String verdict;
    if (riskScore >= 50) {
      verdict = 'high_risk';
    } else if (riskScore >= 20) {
      verdict = 'suspicious';
    } else {
      verdict = 'authentic';
    }

    if (signals.isEmpty) {
      signals.add('Aucun signal suspect détecté dans l\'URL de la photo.');
    }
    if (recommendations.isEmpty) {
      recommendations.add('Continuez à utiliser des photos originales et de bonne qualité.');
    }

    return PhotoAuthenticityResult(
      verdict: verdict,
      riskScore: riskScore,
      signals: signals,
      recommendations: recommendations,
    );
  }

  /// Returns AI-powered photo quality tips based on URL heuristics.
  PhotoQualityResult analyzePhotoQuality(String photoUrl) {
    final issues = <String>[];
    final tips = <String>[];
    int qualityScore = 70; // base

    final urlLower = photoUrl.toLowerCase();

    // Check dimensions hints in URL
    final sizePattern = RegExp(r'(\d+)x(\d+)');
    final sizeMatch = sizePattern.firstMatch(urlLower);
    if (sizeMatch != null) {
      final w = int.tryParse(sizeMatch.group(1) ?? '0') ?? 0;
      final h = int.tryParse(sizeMatch.group(2) ?? '0') ?? 0;
      if (w > 0 && h > 0) {
        if (w < 640 || h < 480) {
          qualityScore -= 20;
          issues.add('Résolution faible détectée (${w}x$h px). Minimum recommandé : 1280×960.');
          tips.add('Utilisez un appareil photo ou smartphone récent (12 MP minimum).');
        } else if (w >= 1920) {
          qualityScore += 10;
          tips.add('Excellente résolution — la photo sera bien affichée sur tous les écrans.');
        }
      }
    }

    // Thumbnail patterns
    if (urlLower.contains('thumb') ||
        urlLower.contains('small') ||
        urlLower.contains('tiny') ||
        urlLower.contains('_sm') ||
        urlLower.contains('-sm')) {
      qualityScore -= 15;
      issues.add('La photo semble être une miniature (thumbnail) de faible résolution.');
      tips.add('Uploadez la version haute résolution de vos photos.');
    }

    // WebP / modern formats → good
    if (urlLower.contains('.webp') || urlLower.contains('.avif')) {
      qualityScore += 5;
      tips.add('Format WebP/AVIF optimisé — bonne performance de chargement.');
    }

    // General tips always provided
    tips.addAll([
      'Photographiez en lumière naturelle (journée, fenêtres ouvertes).',
      'Prenez des photos de toutes les pièces : salon, chambre(s), cuisine, salle de bain.',
      'Rangez et nettoyez le logement avant de photographier.',
      'Utilisez le mode paysage (horizontal) pour les grandes pièces.',
    ]);

    qualityScore = qualityScore.clamp(0, 100);

    return PhotoQualityResult(
      qualityScore: qualityScore,
      issues: issues,
      tips: tips,
    );
  }

  // ── Roommate finder ────────────────────────

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

      int compatScore = 40; // base

      // Lifestyle (20 pts)
      if (myPrefs != null && theirPrefs.lifestyle == myPrefs.lifestyle) {
        compatScore += 20;
      } else if (myPrefs?.lifestyle == 'any' ||
          theirPrefs.lifestyle == 'any') {
        compatScore += 10;
      }

      // Budget overlap (15 pts)
      if (myPrefs != null &&
          myPrefs.budgetMax != null &&
          theirPrefs.budgetMax != null) {
        final myMin = myPrefs.budgetMin ?? 0;
        final theirMin = theirPrefs.budgetMin ?? 0;
        final overlapStart = max(myMin, theirMin);
        final overlapEnd = min(myPrefs.budgetMax!, theirPrefs.budgetMax!);
        if (overlapEnd > overlapStart) compatScore += 15;
      }

      // Language (10 pts)
      if (myPrefs != null &&
          (theirPrefs.preferredLanguage == myPrefs.preferredLanguage ||
              theirPrefs.preferredLanguage == 'any' ||
              myPrefs.preferredLanguage == 'any')) {
        compatScore += 10;
      }

      // Study field (5 pts)
      if (user.studyField != null &&
          currentUser.studyField != null &&
          user.studyField == currentUser.studyField) {
        compatScore += 5;
      }

      // Nationality (5 pts)
      if (user.nationality != null &&
          currentUser.nationality != null &&
          user.nationality == currentUser.nationality) {
        compatScore += 5;
      }

      // New: Schedule compatibility (10 pts)
      if (myPrefs != null) {
        if (theirPrefs.schedule == myPrefs.schedule ||
            theirPrefs.schedule == 'flexible' ||
            myPrefs.schedule == 'flexible') {
          compatScore += 10;
        }
      }

      // New: Cleanliness level (10 pts) — ≤1 level apart is compatible
      if (myPrefs != null) {
        final diff = (theirPrefs.cleanlinessLevel - myPrefs.cleanlinessLevel).abs();
        if (diff == 0) {
          compatScore += 10;
        } else if (diff == 1) {
          compatScore += 5;
        }
      }

      // New: Smoking/pets compatibility (penalty)
      if (myPrefs != null) {
        if (!theirPrefs.smokingAllowed && myPrefs.smokingAllowed) {
          compatScore -= 15;
        }
        if (!theirPrefs.petsAllowed && myPrefs.petsAllowed) {
          compatScore -= 10;
        }
      }

      // New: Shared hobbies (up to 10 pts)
      if (myPrefs != null && myPrefs.hobbies.isNotEmpty) {
        final sharedHobbies = myPrefs.hobbies
            .where((h) => theirPrefs.hobbies.contains(h))
            .length;
        compatScore += min(sharedHobbies * 3, 10);
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
