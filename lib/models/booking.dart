class Booking {
  final String id;
  final String listingId;
  final String tenantId;
  final String ownerId;
  final DateTime scheduledAt;
  final String status; // 'confirmed','pending','cancelled'
  final String qrCode;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.listingId,
    required this.tenantId,
    required this.ownerId,
    required this.scheduledAt,
    required this.status,
    required this.qrCode,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'listingId': listingId,
        'tenantId': tenantId,
        'ownerId': ownerId,
        'scheduledAt': scheduledAt.toIso8601String(),
        'status': status,
        'qrCode': qrCode,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as String,
        listingId: json['listingId'] as String,
        tenantId: json['tenantId'] as String,
        ownerId: json['ownerId'] as String,
        scheduledAt: DateTime.parse(json['scheduledAt'] as String),
        status: json['status'] as String,
        qrCode: json['qrCode'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Booking copyWith({
    String? id,
    String? listingId,
    String? tenantId,
    String? ownerId,
    DateTime? scheduledAt,
    String? status,
    String? qrCode,
    DateTime? createdAt,
  }) =>
      Booking(
        id: id ?? this.id,
        listingId: listingId ?? this.listingId,
        tenantId: tenantId ?? this.tenantId,
        ownerId: ownerId ?? this.ownerId,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        status: status ?? this.status,
        qrCode: qrCode ?? this.qrCode,
        createdAt: createdAt ?? this.createdAt,
      );

  String get statusLabel {
    switch (status) {
      case 'confirmed':
        return 'Confirmée';
      case 'pending':
        return 'En attente';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }
}
