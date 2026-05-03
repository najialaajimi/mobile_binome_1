import 'package:flutter/material.dart';
import '../../services/review_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import 'package:uuid/uuid.dart';

class ListingReviewsScreen extends StatefulWidget {
  final String listingId;
  const ListingReviewsScreen({super.key, required this.listingId});

  @override
  State<ListingReviewsScreen> createState() => _ListingReviewsScreenState();
}

class _ListingReviewsScreenState extends State<ListingReviewsScreen> {
  final _reviewService = ReviewService();
  final _authService = AuthService();

  List<Review> _reviews = [];
  double _avg = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _reviews = _reviewService.getReviewsForListing(widget.listingId);
      _avg = _reviewService.getAverageScore(widget.listingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.getCurrentUser()?.id ?? '';
    final canReview =
        !_reviewService.hasUserReviewed(widget.listingId, userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avis'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.background,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _avg.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _starRow(_avg),
                    Text('${_reviews.length} avis',
                        style: const TextStyle(
                            color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _reviews.isEmpty
                ? const Center(
                    child: Text(
                      'Aucun avis pour ce logement.',
                      style:
                          TextStyle(color: AppColors.textSecondary),
                    ))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reviews.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) {
                      final r = _reviews[i];
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor:
                                      AppColors.primary.withAlpha(20),
                                  child: Text(
                                      r.userName.isNotEmpty
                                          ? r.userName[0]
                                          : '?',
                                      style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight:
                                              FontWeight.bold)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(r.userName,
                                          style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.w600,
                                              color: AppColors
                                                  .textPrimary)),
                                      Text(
                                        '${r.createdAt.day}/${r.createdAt.month}/${r.createdAt.year}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors
                                                .textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                _starRow(r.score),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(r.comment,
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    height: 1.5)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: canReview
          ? FloatingActionButton.extended(
              onPressed: () =>
                  _showReviewDialog(context, userId),
              icon: const Icon(Icons.star_outline),
              label: const Text('Ajouter un avis'),
              backgroundColor: AppColors.secondary,
            )
          : null,
    );
  }

  Widget _starRow(double score) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < score.floor();
        final half = !filled && i < score;
        return Icon(
          filled
              ? Icons.star
              : (half ? Icons.star_half : Icons.star_border),
          color: AppColors.secondary,
          size: 18,
        );
      }),
    );
  }

  void _showReviewDialog(BuildContext context, String userId) {
    double rating = 4;
    final commentCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Votre avis'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Note :'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    5,
                    (i) => GestureDetector(
                          onTap: () => setDialogState(
                              () => rating = (i + 1).toDouble()),
                          child: Icon(
                            i < rating
                                ? Icons.star
                                : Icons.star_border,
                            color: AppColors.secondary,
                            size: 32,
                          ),
                        )),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentCtrl,
                decoration: const InputDecoration(
                    labelText: 'Commentaire',
                    hintText: 'Votre expérience...'),
                maxLines: 3,
                maxLength: 300,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                if (commentCtrl.text.trim().isEmpty) return;
                final user = _authService.getCurrentUser();
                final review = Review(
                  id: const Uuid().v4(),
                  listingId: widget.listingId,
                  userId: userId,
                  userName: user?.fullName ?? 'Anonyme',
                  score: rating,
                  comment: commentCtrl.text.trim(),
                  createdAt: DateTime.now(),
                );
                await _reviewService.addReview(review);
                if (ctx.mounted) Navigator.pop(ctx);
                _load();
              },
              child: const Text('Publier'),
            ),
          ],
        ),
      ),
    );
  }
}
