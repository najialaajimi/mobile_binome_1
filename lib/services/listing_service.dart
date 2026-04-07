import 'dart:convert';
import '../models/listing.dart';
import 'storage_service.dart';

class ListingService {
  static const _listingsKey = 'listings';
  static const _seededKey = 'listings_seeded_v2';

  final StorageService _storage = StorageService.instance;

  Future<void> init() async {
    if (_storage.getBool(_seededKey) != true) {
      await _seedListings();
      await _storage.setBool(_seededKey, true);
    }
  }

  Future<void> _seedListings() async {
    final now = DateTime.now();
    final listings = [
      Listing(
        id: 'listing_1',
        ownerId: 'owner_1',
        title: 'Studio meublé près ESPRIT - Ariana',
        description: 'Studio entièrement meublé et équipé, idéal pour étudiant. Cuisine équipée, salle de bain moderne. Quartier calme, proche ESPRIT et Université de Carthage. Eau et électricité incluses.',
        type: 'studio',
        city: 'Ariana',
        address: '15 rue du Lac, Ariana Ville',
        postalCode: '2080',
        price: 350,
        rooms: 1,
        bedrooms: 1,
        bathrooms: 1,
        surface: 28,
        isFurnished: true,
        photos: [],
        amenities: ['Meublé', 'Cuisine équipée', 'Internet inclus', 'Eau incluse'],
        isAvailable: true,
        availableFrom: now.add(const Duration(days: 5)),
        status: 'active',
        views: 128,
        createdAt: now.subtract(const Duration(days: 20)),
        nearbyUniversities: ['ESPRIT', 'Université de Carthage'],
        targetAudience: ['étudiant', 'étranger'],
        leaseDurationMin: 1,
        leaseDurationMax: 12,
        reviewScore: 4.5,
        reviewCount: 2,
        fraudRisk: 'low',
      ),
      Listing(
        id: 'listing_2',
        ownerId: 'owner_1',
        title: 'Appartement T2 lumineux - Tunis Lac',
        description: 'Bel appartement de 55m² au 3ème étage avec ascenseur. Vue sur le lac, double vitrage. Proche INSAT et ISET. Idéal pour jeune professionnel ou couple d'étudiants.',
        type: 'apartment',
        city: 'Tunis',
        address: '8 avenue du Lac Berges du Lac 1',
        postalCode: '1053',
        price: 700,
        rooms: 2,
        bedrooms: 1,
        bathrooms: 1,
        surface: 55,
        isFurnished: false,
        photos: [],
        amenities: ['Ascenseur', 'Double vitrage', 'Gardien', 'Cave'],
        isAvailable: true,
        availableFrom: now.add(const Duration(days: 15)),
        status: 'active',
        views: 210,
        createdAt: now.subtract(const Duration(days: 10)),
        nearbyUniversities: ['INSAT', 'ISET Tunis'],
        targetAudience: ['étudiant', 'professionnel'],
        leaseDurationMin: 3,
        leaseDurationMax: 12,
        reviewScore: 4.0,
        reviewCount: 1,
        fraudRisk: 'low',
      ),
      Listing(
        id: 'listing_3',
        ownerId: 'owner_2',
        title: 'Colocation étudiante - Sousse Centre',
        description: 'Chambre meublée dans grand appartement T4 avec 3 colocataires. Ambiance sympa et internationale. Proche Université de Sousse et facultés. Charges incluses.',
        type: 'colocation',
        city: 'Sousse',
        address: '22 avenue Habib Bourguiba',
        postalCode: '4000',
        price: 250,
        rooms: 1,
        bedrooms: 1,
        bathrooms: 1,
        surface: 16,
        isFurnished: true,
        photos: [],
        amenities: ['Meublé', 'Charges incluses', 'Internet', 'Machine à laver'],
        isAvailable: true,
        availableFrom: now.add(const Duration(days: 1)),
        status: 'active',
        views: 320,
        createdAt: now.subtract(const Duration(days: 3)),
        nearbyUniversities: ['Université de Sousse'],
        targetAudience: ['étudiant', 'étranger'],
        leaseDurationMin: 1,
        leaseDurationMax: 6,
        reviewScore: 3.5,
        reviewCount: 1,
        fraudRisk: 'low',
      ),
      Listing(
        id: 'listing_4',
        ownerId: 'owner_1',
        title: 'Villa moderne avec piscine - La Marsa',
        description: 'Magnifique villa de 200m² avec piscine et grand jardin. 4 chambres, 2 salles de bain, double garage. Vue sur mer partielle. Quartier résidentiel calme.',
        type: 'house',
        city: 'La Marsa',
        address: '45 rue de la Plage',
        postalCode: '2070',
        price: 2500,
        rooms: 6,
        bedrooms: 4,
        bathrooms: 2,
        surface: 200,
        isFurnished: false,
        photos: [],
        amenities: ['Piscine', 'Jardin', 'Double garage', 'Terrasse', 'Alarme'],
        isAvailable: false,
        availableFrom: now.add(const Duration(days: 60)),
        status: 'active',
        views: 95,
        createdAt: now.subtract(const Duration(days: 30)),
        nearbyUniversities: ['Université de Carthage'],
        targetAudience: ['professionnel'],
        leaseDurationMin: 6,
        leaseDurationMax: 12,
        reviewScore: 0.0,
        reviewCount: 0,
        fraudRisk: 'low',
      ),
      Listing(
        id: 'listing_5',
        ownerId: 'owner_2',
        title: 'Studio étudiant - Sfax Médina',
        description: 'Studio meublé de 25m² idéal pour étudiant. Proche Université de Sfax et faculté de médecine. Tout équipé, eau et internet inclus.',
        type: 'studio',
        city: 'Sfax',
        address: '7 rue Mongi Slim',
        postalCode: '3000',
        price: 280,
        rooms: 1,
        bedrooms: 1,
        bathrooms: 1,
        surface: 25,
        isFurnished: true,
        photos: [],
        amenities: ['Meublé', 'Internet', 'Eau incluse', 'Climatisation'],
        isAvailable: true,
        availableFrom: now.add(const Duration(days: 3)),
        status: 'active',
        views: 85,
        createdAt: now.subtract(const Duration(days: 8)),
        nearbyUniversities: ['Université de Sfax'],
        targetAudience: ['étudiant'],
        leaseDurationMin: 1,
        leaseDurationMax: 12,
        reviewScore: 5.0,
        reviewCount: 1,
        fraudRisk: 'low',
      ),
      Listing(
        id: 'listing_6',
        ownerId: 'owner_1',
        title: 'Appartement T3 familial - Monastir',
        description: 'Bel appartement de 80m² dans résidence sécurisée. 2 chambres, salon spacieux, balcon. Proche Université de Monastir et plages.',
        type: 'apartment',
        city: 'Monastir',
        address: '3 rue Ibn Khaldoun',
        postalCode: '5000',
        price: 550,
        rooms: 3,
        bedrooms: 2,
        bathrooms: 1,
        surface: 80,
        isFurnished: false,
        photos: [],
        amenities: ['Balcon', 'Gardien', 'Cave', 'Parking'],
        isAvailable: true,
        availableFrom: now.add(const Duration(days: 20)),
        status: 'active',
        views: 67,
        createdAt: now.subtract(const Duration(days: 15)),
        nearbyUniversities: ['Université de Monastir'],
        targetAudience: ['étudiant', 'professionnel'],
        leaseDurationMin: 3,
        leaseDurationMax: 12,
        reviewScore: 0.0,
        reviewCount: 0,
        fraudRisk: 'low',
      ),
      Listing(
        id: 'listing_7',
        ownerId: 'owner_2',
        title: 'Chambre meublée - Nabeul Université',
        description: 'Chambre individuelle meublée dans appartement partagé. 2 colocataires, ambiance internationale. Proche ISTP Nabeul. Cuisine et salle de bain communes.',
        type: 'room',
        city: 'Nabeul',
        address: '18 avenue Habib Thameur',
        postalCode: '8000',
        price: 200,
        rooms: 1,
        bedrooms: 1,
        bathrooms: 1,
        surface: 12,
        isFurnished: true,
        photos: [],
        amenities: ['Meublé', 'Cuisine partagée', 'Internet', 'Charges incluses'],
        isAvailable: true,
        availableFrom: now,
        status: 'active',
        views: 145,
        createdAt: now.subtract(const Duration(days: 5)),
        nearbyUniversities: ['Université de Sousse'],
        targetAudience: ['étudiant', 'étranger'],
        leaseDurationMin: 1,
        leaseDurationMax: 6,
        reviewScore: 0.0,
        reviewCount: 0,
        fraudRisk: 'low',
      ),
      Listing(
        id: 'listing_8',
        ownerId: 'owner_1',
        title: 'Grand appartement ISG - Tunis Menzah',
        description: 'Appartement spacieux de 100m² à 5 min à pied de l'ISG Tunis. 3 chambres, grande cuisine, 2 salles de bain. Idéal pour famille ou groupe d'étudiants.',
        type: 'apartment',
        city: 'Tunis',
        address: '12 rue Alain Savary, El Menzah 6',
        postalCode: '1004',
        price: 900,
        rooms: 4,
        bedrooms: 3,
        bathrooms: 2,
        surface: 100,
        isFurnished: false,
        photos: [],
        amenities: ['Cave', 'Gardien', 'Parking', 'Balcon'],
        isAvailable: true,
        availableFrom: now.add(const Duration(days: 45)),
        status: 'draft',
        views: 12,
        createdAt: now.subtract(const Duration(days: 2)),
        nearbyUniversities: ['ISG Tunis', 'Université de Tunis'],
        targetAudience: ['étudiant', 'professionnel'],
        leaseDurationMin: 6,
        leaseDurationMax: 12,
        reviewScore: 0.0,
        reviewCount: 0,
        fraudRisk: 'low',
      ),
      Listing(
        id: 'listing_9',
        ownerId: 'owner_2',
        title: 'Studio INSAT - Tunis Riadh El Andalous',
        description: 'Studio de 30m² parfaitement situé à 10 min de l'INSAT. Meublé, climatisé, internet haut débit inclus. Idéal pour ingénieurs et étudiants en informatique.',
        type: 'studio',
        city: 'Tunis',
        address: '5 rue des Roses, Riadh El Andalous',
        postalCode: '1012',
        price: 400,
        rooms: 1,
        bedrooms: 1,
        bathrooms: 1,
        surface: 30,
        isFurnished: true,
        photos: [],
        amenities: ['Meublé', 'Climatisation', 'Internet inclus', 'Parking'],
        isAvailable: true,
        availableFrom: now.add(const Duration(days: 7)),
        status: 'active',
        views: 189,
        createdAt: now.subtract(const Duration(days: 12)),
        nearbyUniversities: ['INSAT', 'Université de Tunis'],
        targetAudience: ['étudiant'],
        leaseDurationMin: 1,
        leaseDurationMax: 12,
        reviewScore: 0.0,
        reviewCount: 0,
        fraudRisk: 'low',
      ),
      Listing(
        id: 'listing_10',
        ownerId: 'owner_1',
        title: 'Appartement meublé - Bizerte Corniche',
        description: 'Appartement de 70m² vue mer, entièrement meublé. Proche Université de Carthage campus Bizerte. 2 chambres, salon lumineux, terrasse.',
        type: 'apartment',
        city: 'Bizerte',
        address: '33 avenue Habib Bourguiba, Corniche',
        postalCode: '7000',
        price: 500,
        rooms: 3,
        bedrooms: 2,
        bathrooms: 1,
        surface: 70,
        isFurnished: true,
        photos: [],
        amenities: ['Meublé', 'Terrasse', 'Vue mer', 'Parking'],
        isAvailable: true,
        availableFrom: now.add(const Duration(days: 10)),
        status: 'active',
        views: 156,
        createdAt: now.subtract(const Duration(days: 7)),
        nearbyUniversities: ['Université de Carthage'],
        targetAudience: ['étudiant', 'étranger', 'professionnel'],
        leaseDurationMin: 3,
        leaseDurationMax: 12,
        reviewScore: 0.0,
        reviewCount: 0,
        fraudRisk: 'low',
      ),
    ];
    final encoded = listings.map((l) => jsonEncode(l.toJson())).toList();
    await _storage.setStringList(_listingsKey, encoded);
  }
  List<Listing> _getAll() {
    final list = _storage.getStringList(_listingsKey) ?? [];
    return list
        .map((s) => Listing.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveAll(List<Listing> listings) async {
    final encoded = listings.map((l) => jsonEncode(l.toJson())).toList();
    await _storage.setStringList(_listingsKey, encoded);
  }

  List<Listing> getListings() => _getAll();

  Listing? getListingById(String id) {
    try {
      return _getAll().firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Listing> getListingsByOwner(String ownerId) =>
      _getAll().where((l) => l.ownerId == ownerId).toList();

  Future<void> createListing(Listing listing) async {
    final listings = _getAll();
    listings.add(listing);
    await _saveAll(listings);
  }

  Future<bool> updateListing(Listing listing) async {
    final listings = _getAll();
    final idx = listings.indexWhere((l) => l.id == listing.id);
    if (idx < 0) return false;
    listings[idx] = listing;
    await _saveAll(listings);
    return true;
  }

  Future<bool> deleteListing(String id) async {
    final listings = _getAll();
    final updated = listings.where((l) => l.id != id).toList();
    if (updated.length == listings.length) return false;
    await _saveAll(updated);
    return true;
  }

  List<Listing> searchListings({
    String? city,
    double? minPrice,
    double? maxPrice,
    String? type,
    double? minSurface,
    double? maxSurface,
    bool? isFurnished,
  }) {
    return _getAll().where((l) {
      if (l.status != 'active') return false;
      if (city != null &&
          city.isNotEmpty &&
          !l.city.toLowerCase().contains(city.toLowerCase())) return false;
      if (minPrice != null && l.price < minPrice) return false;
      if (maxPrice != null && l.price > maxPrice) return false;
      if (type != null && type.isNotEmpty && l.type != type) return false;
      if (minSurface != null && l.surface < minSurface) return false;
      if (maxSurface != null && l.surface > maxSurface) return false;
      if (isFurnished != null && l.isFurnished != isFurnished) return false;
      return true;
    }).toList();
  }

  Future<void> incrementViews(String id) async {
    final listings = _getAll();
    final idx = listings.indexWhere((l) => l.id == id);
    if (idx < 0) return;
    listings[idx] = listings[idx].copyWith(views: listings[idx].views + 1);
    await _saveAll(listings);
  }
}
