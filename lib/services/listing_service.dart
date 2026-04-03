import 'dart:convert';
import '../models/listing.dart';
import 'storage_service.dart';

class ListingService {
  static const _listingsKey = 'listings';
  static const _seededKey = 'listings_seeded';

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
        title: 'Bel appartement 3 pièces - Paris 11ème',
        description:
            'Magnifique appartement lumineux au 3ème étage sans ascenseur. Entièrement rénové, parquet, double vitrage. Proche métro Voltaire.',
        type: 'apartment',
        city: 'Paris',
        address: '12 rue de la Roquette',
        postalCode: '75011',
        price: 1450,
        rooms: 3,
        bedrooms: 2,
        bathrooms: 1,
        surface: 65,
        isFurnished: false,
        photos: [],
        amenities: ['Parquet', 'Double vitrage', 'Cave', 'Interphone'],
        isAvailable: true,
        availableFrom: now.add(const Duration(days: 15)),
        status: 'active',
        views: 128,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Listing(
        id: 'listing_2',
        ownerId: 'owner_1',
        title: 'Studio meublé cosy - Lyon 6ème',
        description:
            'Studio entièrement meublé et équipé, idéal pour étudiant ou jeune professionnel. Cuisine équipée, salle de bain moderne. Quartier calme.',
        type: 'studio',
        city: 'Lyon',
        address: '8 avenue Foch',
        postalCode: '69006',
        price: 650,
        rooms: 1,
        bedrooms: 1,
        bathrooms: 1,
        surface: 28,
        isFurnished: true,
        photos: [],
        amenities: ['Meublé', 'Cuisine équipée', 'Internet inclus', 'Digicode'],
        isAvailable: true,
        availableFrom: now.add(const Duration(days: 5)),
        status: 'active',
        views: 85,
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      Listing(
        id: 'listing_3',
        ownerId: 'owner_2',
        title: 'Maison familiale avec jardin - Marseille',
        description:
            'Belle maison de 5 pièces avec jardin privatif de 200m². Garage double, cuisine ouverte sur séjour. Quartier résidentiel calme, proche école.',
        type: 'house',
        city: 'Marseille',
        address: '45 chemin des Collines',
        postalCode: '13009',
        price: 1800,
        rooms: 5,
        bedrooms: 3,
        bathrooms: 2,
        surface: 130,
        isFurnished: false,
        photos: [],
        amenities: ['Jardin', 'Garage', 'Terrasse', 'Cave', 'Alarme'],
        isAvailable: true,
        availableFrom: now.add(const Duration(days: 30)),
        status: 'active',
        views: 210,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Listing(
        id: 'listing_4',
        ownerId: 'owner_1',
        title: 'Chambre en colocation - Paris 20ème',
        description:
            'Chambre meublée dans beau T4 avec 3 colocataires. Colocation mixte, ambiance sympa. Charges incluses. Proche métro Gambetta.',
        type: 'colocation',
        city: 'Paris',
        address: '27 rue des Pyrénées',
        postalCode: '75020',
        price: 550,
        rooms: 1,
        bedrooms: 1,
        bathrooms: 1,
        surface: 14,
        isFurnished: true,
        photos: [],
        amenities: ['Meublé', 'Charges incluses', 'Internet', 'Machine à laver'],
        isAvailable: true,
        availableFrom: now.add(const Duration(days: 1)),
        status: 'active',
        views: 320,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Listing(
        id: 'listing_5',
        ownerId: 'owner_2',
        title: 'Appartement T2 lumineux - Bordeaux',
        description:
            'Charmant appartement de 45m² au 5ème étage avec ascenseur. Vue sur les toits, très lumineux. Parking en option.',
        type: 'apartment',
        city: 'Bordeaux',
        address: '3 cours du Chapeau Rouge',
        postalCode: '33000',
        price: 850,
        rooms: 2,
        bedrooms: 1,
        bathrooms: 1,
        surface: 45,
        isFurnished: false,
        photos: [],
        amenities: ['Ascenseur', 'Digicode', 'Cave', 'Parking optionnel'],
        isAvailable: true,
        availableFrom: now.add(const Duration(days: 20)),
        status: 'active',
        views: 67,
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      Listing(
        id: 'listing_6',
        ownerId: 'owner_1',
        title: 'Studio moderne - Toulouse Centre',
        description:
            'Studio neuf de 32m² dans résidence sécurisée. Tout équipé, climatisation, parking inclus. Idéal pour étudiant ou professionnel.',
        type: 'studio',
        city: 'Toulouse',
        address: '15 place du Capitole',
        postalCode: '31000',
        price: 720,
        rooms: 1,
        bedrooms: 1,
        bathrooms: 1,
        surface: 32,
        isFurnished: true,
        photos: [],
        amenities: ['Climatisation', 'Parking', 'Gardien', 'Piscine'],
        isAvailable: true,
        availableFrom: now,
        status: 'active',
        views: 145,
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      Listing(
        id: 'listing_7',
        ownerId: 'owner_2',
        title: 'Grande maison T6 - Nice Ouest',
        description:
            'Spacieuse villa de 180m² avec piscine et grand jardin. 4 chambres, 2 salles de bain, double garage. Vue sur mer partielle.',
        type: 'house',
        city: 'Nice',
        address: '88 boulevard de Cimiez',
        postalCode: '06000',
        price: 2800,
        rooms: 6,
        bedrooms: 4,
        bathrooms: 2,
        surface: 180,
        isFurnished: false,
        photos: [],
        amenities: ['Piscine', 'Jardin', 'Double garage', 'Terrasse', 'Alarme'],
        isAvailable: false,
        availableFrom: now.add(const Duration(days: 60)),
        status: 'active',
        views: 95,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Listing(
        id: 'listing_8',
        ownerId: 'owner_1',
        title: 'Appartement T4 familial - Lyon 3ème',
        description:
            'Grand appartement de 90m² idéal pour famille. 3 chambres, salon-séjour de 30m², cuisine séparée. Proche écoles et commerces.',
        type: 'apartment',
        city: 'Lyon',
        address: '22 cours Lafayette',
        postalCode: '69003',
        price: 1350,
        rooms: 4,
        bedrooms: 3,
        bathrooms: 1,
        surface: 90,
        isFurnished: false,
        photos: [],
        amenities: ['Cave', 'Gardien', 'Parking', 'Balcon'],
        isAvailable: true,
        availableFrom: now.add(const Duration(days: 45)),
        status: 'draft',
        views: 12,
        createdAt: now.subtract(const Duration(days: 2)),
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
