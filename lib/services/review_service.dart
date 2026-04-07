import 'dart:convert';
import '../services/storage_service.dart';

class Review {
  final String id;
  final String listingId;
  final String userId;
  final String userName;
  final double score;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.listingId,
    required this.userId,
    required this.userName,
    required this.score,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'listingId': listingId,
        'userId': userId,
        'userName': userName,
        'score': score,
        'comment': comment,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as String,
        listingId: json['listingId'] as String,
        userId: json['userId'] as String,
        userName: json['userName'] as String,
        score: (json['score'] as num).toDouble(),
        comment: json['comment'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class ReviewService {
  static const _reviewsKey = 'reviews_';
  static const _seededKey = 'reviews_seeded';
  final StorageService _storage = StorageService.instance;

  Future<void> init() async {
    if (_storage.getBool(_seededKey) != true) {
      await _seedReviews();
      await _storage.setBool(_seededKey, true);
    }
  }

  Future<void> _seedReviews() async {
    final now = DateTime.now();
    final seedData = {
      'listing_1': [
        Review(
            id: 'rev_1',
            listingId: 'listing_1',
            userId: 'tenant_1',
            userName: 'Ahmed B.',
            score: 4.5,
            comment:
                'Très bon logement, proche de l\'université. Propriétaire réactif.',
            createdAt: now.subtract(const Duration(days: 30))),
        Review(
            id: 'rev_2',
            listingId: 'listing_1',
            userId: 'tenant_2',
            userName: 'Fatma K.',
            score: 4.0,
            comment: 'Appartement propre et bien situé. Recommande!',
            createdAt: now.subtract(const Duration(days: 15))),
      ],
      'listing_2': [
        Review(
            id: 'rev_3',
            listingId: 'listing_2',
            userId: 'tenant_1',
            userName: 'Mohamed S.',
            score: 5.0,
            comment: 'Studio parfait pour étudiant, tout équipé.',
            createdAt: now.subtract(const Duration(days: 20))),
      ],
      'listing_3': [
        Review(
            id: 'rev_4',
            listingId: 'listing_3',
            userId: 'tenant_2',
            userName: 'Sarra L.',
            score: 3.5,
            comment: 'Bien mais un peu loin du centre.',
            createdAt: now.subtract(const Duration(days: 10))),
      ],
    };
    for (final entry in seedData.entries) {
      final encoded =
          entry.value.map((r) => jsonEncode(r.toJson())).toList();
      await _storage.setStringList('$_reviewsKey${entry.key}', encoded);
    }
  }

  List<Review> getReviewsForListing(String listingId) {
    final list =
        _storage.getStringList('$_reviewsKey$listingId') ?? [];
    return list
        .map((s) =>
            Review.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> addReview(Review review) async {
    final reviews = getReviewsForListing(review.listingId);
    reviews.add(review);
    final encoded = reviews.map((r) => jsonEncode(r.toJson())).toList();
    await _storage.setStringList(
        '$_reviewsKey${review.listingId}', encoded);
  }

  double getAverageScore(String listingId) {
    final reviews = getReviewsForListing(listingId);
    if (reviews.isEmpty) return 0.0;
    final total = reviews.fold(0.0, (sum, r) => sum + r.score);
    return total / reviews.length;
  }

  bool hasUserReviewed(String listingId, String userId) {
    return getReviewsForListing(listingId).any((r) => r.userId == userId);
  }
}
