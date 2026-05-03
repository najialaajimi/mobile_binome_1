class RentalApplication {
  final String id;
  final String listingId;
  final String tenantId;
  final String ownerId;
  final String message;
  final DateTime desiredMoveIn;
  final String status; // 'pending','accepted','rejected'
  final DateTime createdAt;
  final List<String> tenantBadges;

  RentalApplication({
    required this.id,
    required this.listingId,
    required this.tenantId,
    required this.ownerId,
    required this.message,
    required this.desiredMoveIn,
    required this.status,
    required this.createdAt,
    required this.tenantBadges,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'listingId': listingId,
        'tenantId': tenantId,
        'ownerId': ownerId,
        'message': message,
        'desiredMoveIn': desiredMoveIn.toIso8601String(),
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'tenantBadges': tenantBadges,
      };

  factory RentalApplication.fromJson(Map<String, dynamic> json) =>
      RentalApplication(
        id: json['id'] as String,
        listingId: json['listingId'] as String,
        tenantId: json['tenantId'] as String,
        ownerId: json['ownerId'] as String,
        message: json['message'] as String,
        desiredMoveIn: DateTime.parse(json['desiredMoveIn'] as String),
        status: json['status'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        tenantBadges: List<String>.from(json['tenantBadges'] as List),
      );

  RentalApplication copyWith({
    String? id,
    String? listingId,
    String? tenantId,
    String? ownerId,
    String? message,
    DateTime? desiredMoveIn,
    String? status,
    DateTime? createdAt,
    List<String>? tenantBadges,
  }) =>
      RentalApplication(
        id: id ?? this.id,
        listingId: listingId ?? this.listingId,
        tenantId: tenantId ?? this.tenantId,
        ownerId: ownerId ?? this.ownerId,
        message: message ?? this.message,
        desiredMoveIn: desiredMoveIn ?? this.desiredMoveIn,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        tenantBadges: tenantBadges ?? this.tenantBadges,
      );

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'accepted':
        return 'Acceptée';
      case 'rejected':
        return 'Refusée';
      default:
        return status;
    }
  }
}
