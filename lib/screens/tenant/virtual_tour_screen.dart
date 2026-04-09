import 'package:flutter/material.dart';
import '../../utils/constants.dart';

/// Simulated 360° virtual tour screen.
/// Displays each 360° photo URL with an interactive pan-indicator UI.
/// In a real app, this would use a panorama SDK (e.g. panorama_viewer package).
class VirtualTourScreen extends StatefulWidget {
  final String listingTitle;
  final List<String> photos360;

  const VirtualTourScreen({
    super.key,
    required this.listingTitle,
    required this.photos360,
  });

  @override
  State<VirtualTourScreen> createState() => _VirtualTourScreenState();
}

class _VirtualTourScreenState extends State<VirtualTourScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _rotationController;
  late final Animation<double> _rotationAnim;

  // Simulated pan offset to fake a 360 look
  Offset _panOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _rotationAnim =
        Tween<double>(begin: 0, end: 1).animate(_rotationController);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  String get _currentUrl => widget.photos360[_currentIndex];

  void _prev() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _panOffset = Offset.zero;
      });
    }
  }

  void _next() {
    if (_currentIndex < widget.photos360.length - 1) {
      setState(() {
        _currentIndex++;
        _panOffset = Offset.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🌐 Visite Virtuelle 360°',
                style: TextStyle(fontSize: 16)),
            Text(
              widget.listingTitle,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 360 viewer area
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _panOffset += details.delta;
                });
              },
              child: Stack(
                children: [
                  // Background: simulated panorama with gradient that shifts on pan
                  AnimatedBuilder(
                    animation: _rotationAnim,
                    builder: (ctx, _) {
                      final hueShift = (_panOffset.dx / 5 + _rotationAnim.value * 30) % 360;
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(
                                (_panOffset.dx / 200).clamp(-1.0, 1.0),
                                (_panOffset.dy / 200).clamp(-1.0, 1.0)),
                            end: Alignment(
                                (1 - _panOffset.dx / 200).clamp(-1.0, 1.0),
                                (1 - _panOffset.dy / 200).clamp(-1.0, 1.0)),
                            colors: [
                              HSVColor.fromAHSV(1, hueShift % 360, 0.6, 0.25).toColor(),
                              HSVColor.fromAHSV(1, (hueShift + 40) % 360, 0.5, 0.15).toColor(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Photo rendered with parallax translation
                  Center(
                    child: Transform.translate(
                      offset: Offset(
                        (_panOffset.dx % 120) - 60,
                        (_panOffset.dy % 80) - 40,
                      ),
                      child: _PanoramaCard(photoUrl: _currentUrl),
                    ),
                  ),

                  // 360° badge
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(160),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withAlpha(80)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.threed_rotation,
                              size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text('360°',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),

                  // Pan hint
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: _panOffset == Offset.zero ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 400),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(140),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.swipe, size: 14, color: Colors.white70),
                              SizedBox(width: 6),
                              Text(
                                'Glissez pour explorer la vue 360°',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom controls
          Container(
            color: Colors.black,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              children: [
                // Room counter
                Text(
                  'Pièce ${_currentIndex + 1} / ${widget.photos360.length}',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 10),
                // Navigation dots
                if (widget.photos360.length > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.photos360.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _currentIndex ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentIndex
                              ? AppColors.primaryLight
                              : Colors.white30,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                // Prev / Next
                if (widget.photos360.length > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _currentIndex > 0 ? _prev : null,
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Précédent'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white12,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.white10,
                          disabledForegroundColor: Colors.white30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _currentIndex < widget.photos360.length - 1
                            ? _next
                            : null,
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text('Suivant'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.white10,
                          disabledForegroundColor: Colors.white30,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders the panorama photo URL as a card with an icon (since we can't
/// render actual network images in this offline-first app).
class _PanoramaCard extends StatelessWidget {
  final String photoUrl;

  const _PanoramaCard({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(40)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.panorama_outlined,
              size: 60, color: Colors.white70),
          const SizedBox(height: 12),
          const Text(
            'Vue 360°',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              photoUrl.length > 50
                  ? '${photoUrl.substring(0, 47)}…'
                  : photoUrl,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(120),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Glissez pour pivoter',
              style: TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
