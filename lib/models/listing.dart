class Listing {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final String type;
  final String city;
  final String address;
  final String postalCode;
  final double price;
  final int rooms;
  final int bedrooms;
  final int bathrooms;
  final double surface;
  final bool isFurnished;
  final List<String> photos;
  final List<String> amenities;
  final bool isAvailable;
  final DateTime? availableFrom;
  final String status;
  final int views;
  final DateTime createdAt;
  final List<String> nearbyUniversities;
  final int leaseDurationMin;
  final int leaseDurationMax;
  final double reviewScore;
  final int reviewCount;
  final String fraudRisk;
  final List<String> targetAudience;
  final List<String> photos360;

  Listing({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.type,
    required this.city,
    required this.address,
    required this.postalCode,
    required this.price,
    required this.rooms,
    required this.bedrooms,
    required this.bathrooms,
    required this.surface,
    required this.isFurnished,
    required this.photos,
    required this.amenities,
    required this.isAvailable,
    this.availableFrom,
    required this.status,
    this.views = 0,
    required this.createdAt,
    this.nearbyUniversities = const [],
    this.leaseDurationMin = 1,
    this.leaseDurationMax = 12,
    this.reviewScore = 0.0,
    this.reviewCount = 0,
    this.fraudRisk = 'low',
    this.targetAudience = const [],
    this.photos360 = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerId': ownerId,
        'title': title,
        'description': description,
        'type': type,
        'city': city,
        'address': address,
        'postalCode': postalCode,
        'price': price,
        'rooms': rooms,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'surface': surface,
        'isFurnished': isFurnished,
        'photos': photos,
        'amenities': amenities,
        'isAvailable': isAvailable,
        'availableFrom': availableFrom?.toIso8601String(),
        'status': status,
        'views': views,
        'createdAt': createdAt.toIso8601String(),
        'nearbyUniversities': nearbyUniversities,
        'leaseDurationMin': leaseDurationMin,
        'leaseDurationMax': leaseDurationMax,
        'reviewScore': reviewScore,
        'reviewCount': reviewCount,
        'fraudRisk': fraudRisk,
        'targetAudience': targetAudience,
        'photos360': photos360,
      };

  factory Listing.fromJson(Map<String, dynamic> json) => Listing(
        id: json['id'] as String,
        ownerId: json['ownerId'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        type: json['type'] as String,
        city: json['city'] as String,
        address: json['address'] as String,
        postalCode: json['postalCode'] as String,
        price: (json['price'] as num).toDouble(),
        rooms: json['rooms'] as int,
        bedrooms: json['bedrooms'] as int,
        bathrooms: json['bathrooms'] as int,
        surface: (json['surface'] as num).toDouble(),
        isFurnished: json['isFurnished'] as bool,
        photos: List<String>.from(json['photos'] as List),
        amenities: List<String>.from(json['amenities'] as List),
        isAvailable: json['isAvailable'] as bool,
        availableFrom: json['availableFrom'] != null
            ? DateTime.parse(json['availableFrom'] as String)
            : null,
        status: json['status'] as String,
        views: json['views'] as int? ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
        nearbyUniversities: json['nearbyUniversities'] != null
            ? List<String>.from(json['nearbyUniversities'] as List)
            : [],
        leaseDurationMin: json['leaseDurationMin'] as int? ?? 1,
        leaseDurationMax: json['leaseDurationMax'] as int? ?? 12,
        reviewScore: (json['reviewScore'] as num?)?.toDouble() ?? 0.0,
        reviewCount: json['reviewCount'] as int? ?? 0,
        fraudRisk: json['fraudRisk'] as String? ?? 'low',
        targetAudience: json['targetAudience'] != null
            ? List<String>.from(json['targetAudience'] as List)
            : [],
        photos360: json['photos360'] != null
            ? List<String>.from(json['photos360'] as List)
            : [],
      );

  Listing copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    String? type,
    String? city,
    String? address,
    String? postalCode,
    double? price,
    int? rooms,
    int? bedrooms,
    int? bathrooms,
    double? surface,
    bool? isFurnished,
    List<String>? photos,
    List<String>? amenities,
    bool? isAvailable,
    DateTime? availableFrom,
    String? status,
    int? views,
    DateTime? createdAt,
    List<String>? nearbyUniversities,
    int? leaseDurationMin,
    int? leaseDurationMax,
    double? reviewScore,
    int? reviewCount,
    String? fraudRisk,
    List<String>? targetAudience,
    List<String>? photos360,
  }) =>
      Listing(
        id: id ?? this.id,
        ownerId: ownerId ?? this.ownerId,
        title: title ?? this.title,
        description: description ?? this.description,
        type: type ?? this.type,
        city: city ?? this.city,
        address: address ?? this.address,
        postalCode: postalCode ?? this.postalCode,
        price: price ?? this.price,
        rooms: rooms ?? this.rooms,
        bedrooms: bedrooms ?? this.bedrooms,
        bathrooms: bathrooms ?? this.bathrooms,
        surface: surface ?? this.surface,
        isFurnished: isFurnished ?? this.isFurnished,
        photos: photos ?? this.photos,
        amenities: amenities ?? this.amenities,
        isAvailable: isAvailable ?? this.isAvailable,
        availableFrom: availableFrom ?? this.availableFrom,
        status: status ?? this.status,
        views: views ?? this.views,
        createdAt: createdAt ?? this.createdAt,
        nearbyUniversities: nearbyUniversities ?? this.nearbyUniversities,
        leaseDurationMin: leaseDurationMin ?? this.leaseDurationMin,
        leaseDurationMax: leaseDurationMax ?? this.leaseDurationMax,
        reviewScore: reviewScore ?? this.reviewScore,
        reviewCount: reviewCount ?? this.reviewCount,
        fraudRisk: fraudRisk ?? this.fraudRisk,
        targetAudience: targetAudience ?? this.targetAudience,
        photos360: photos360 ?? this.photos360,
      );

  String get typeLabel {
    switch (type) {
      case 'apartment':
        return 'Appartement';
      case 'house':
        return 'Maison';
      case 'studio':
        return 'Studio';
      case 'room':
        return 'Chambre';
      case 'colocation':
        return 'Colocation';
      default:
        return type;
    }
  }
}
