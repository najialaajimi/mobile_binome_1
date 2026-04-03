class Listing {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final String type; // 'apartment','house','studio','room','colocation'
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
  final String status; // 'active','draft','archived'
  final int views;
  final DateTime createdAt;

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
