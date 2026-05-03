import 'package:flutter/material.dart';
import '../../services/ai_service.dart';
import '../../utils/constants.dart';

/// Dedicated screen for AI photo authenticity analysis (GAN detection).
/// Accepts a list of photo URLs and shows per-photo analysis results.
class PhotoAnalysisScreen extends StatefulWidget {
  final List<String> photos;

  const PhotoAnalysisScreen({super.key, required this.photos});

  @override
  State<PhotoAnalysisScreen> createState() => _PhotoAnalysisScreenState();
}

class _PhotoAnalysisScreenState extends State<PhotoAnalysisScreen> {
  final _aiService = AiService();
  late final List<_PhotoResult> _results;
  bool _analyzed = false;

  @override
  void initState() {
    super.initState();
    _results = widget.photos
        .map((url) => _PhotoResult(url: url))
        .toList();
  }

  void _analyzeAll() {
    setState(() {
      for (final r in _results) {
        r.authenticity = _aiService.analyzePhotoAuthenticity(r.url);
        r.quality = _aiService.analyzePhotoQuality(r.url);
      }
      _analyzed = true;
    });
  }

  Color _verdictColor(String verdict) {
    switch (verdict) {
      case 'authentic':
        return AppColors.success;
      case 'suspicious':
        return AppColors.secondary;
      default:
        return AppColors.error;
    }
  }

  IconData _verdictIcon(String verdict) {
    switch (verdict) {
      case 'authentic':
        return Icons.verified_outlined;
      case 'suspicious':
        return Icons.warning_amber_outlined;
      default:
        return Icons.block_outlined;
    }
  }

  String _verdictLabel(String verdict) {
    switch (verdict) {
      case 'authentic':
        return 'Authentique';
      case 'suspicious':
        return 'Suspecte';
      default:
        return 'GAN probable';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Analyse IA des photos'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: widget.photos.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_library_outlined,
                        size: 64, color: AppColors.textSecondary),
                    SizedBox(height: 16),
                    Text(
                      'Aucune photo à analyser.',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Ajoutez des photos à votre annonce, puis lancez l\'analyse IA.',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Header card
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_fix_high,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Détection GAN & Authenticité',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Analyse ${widget.photos.length} photo(s) pour détecter les images générées par IA (GAN/Diffusion), les photos de stock et les signaux suspects.',
                        style: TextStyle(
                            color: Colors.white.withAlpha(210), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Analyze button
                if (!_analyzed)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _analyzeAll,
                        icon: const Icon(Icons.search),
                        label: Text(
                            'Analyser ${widget.photos.length} photo(s)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                if (_analyzed)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSummaryBanner(),
                  ),
                const SizedBox(height: 12),
                // Photo list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _results.length,
                    itemBuilder: (ctx, i) =>
                        _PhotoCard(
                          result: _results[i],
                          index: i + 1,
                          analyzed: _analyzed,
                          verdictColor: _verdictColor,
                          verdictIcon: _verdictIcon,
                          verdictLabel: _verdictLabel,
                        ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryBanner() {
    final high = _results
        .where((r) => r.authenticity?.verdict == 'high_risk')
        .length;
    final suspicious = _results
        .where((r) => r.authenticity?.verdict == 'suspicious')
        .length;
    final ok = _results
        .where((r) => r.authenticity?.verdict == 'authentic')
        .length;

    Color color;
    IconData icon;
    String text;
    if (high > 0) {
      color = AppColors.error;
      icon = Icons.dangerous_outlined;
      text = '$high photo(s) à risque élevé (GAN probable). Remplacez-les.';
    } else if (suspicious > 0) {
      color = AppColors.secondary;
      icon = Icons.warning_amber_outlined;
      text = '$suspicious photo(s) suspecte(s). Vérifiez-les.';
    } else {
      color = AppColors.success;
      icon = Icons.check_circle_outline;
      text = 'Toutes les $ok photo(s) semblent authentiques.';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _PhotoResult {
  final String url;
  PhotoAuthenticityResult? authenticity;
  PhotoQualityResult? quality;

  _PhotoResult({required this.url});
}

class _PhotoCard extends StatefulWidget {
  final _PhotoResult result;
  final int index;
  final bool analyzed;
  final Color Function(String) verdictColor;
  final IconData Function(String) verdictIcon;
  final String Function(String) verdictLabel;

  const _PhotoCard({
    required this.result,
    required this.index,
    required this.analyzed,
    required this.verdictColor,
    required this.verdictIcon,
    required this.verdictLabel,
  });

  @override
  State<_PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<_PhotoCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final auth = widget.result.authenticity;
    final qual = widget.result.quality;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // URL row + verdict badge
            Row(
              children: [
                const Icon(Icons.photo_outlined,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Photo ${widget.index}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                ),
                if (widget.analyzed && auth != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget
                          .verdictColor(auth.verdict)
                          .withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.verdictIcon(auth.verdict),
                            size: 13,
                            color: widget.verdictColor(auth.verdict)),
                        const SizedBox(width: 4),
                        Text(
                          widget.verdictLabel(auth.verdict),
                          style: TextStyle(
                              color: widget.verdictColor(auth.verdict),
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.result.url,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            if (widget.analyzed && auth != null) ...[
              const SizedBox(height: 12),
              // Risk score bar
              Row(
                children: [
                  const Text('Risque :',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: auth.riskScore / 100,
                        backgroundColor:
                            AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            widget.verdictColor(auth.verdict)),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${auth.riskScore}%',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: widget.verdictColor(auth.verdict))),
                ],
              ),
              const SizedBox(height: 8),
              // Quality score
              if (qual != null)
                Row(
                  children: [
                    const Text('Qualité :',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: qual.qualityScore / 100,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${qual.qualityScore}%',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                  ],
                ),
              const SizedBox(height: 8),
              // Expand/collapse details
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Row(
                  children: [
                    Text(
                      _expanded
                          ? 'Masquer les détails'
                          : 'Voir les détails',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                    Icon(
                      _expanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              if (_expanded) ...[
                const SizedBox(height: 10),
                const Text('Signaux détectés :',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                ...auth.signals.map((s) => _SignalRow(
                      text: s,
                      isNegative: auth.riskScore > 0,
                    )),
                if (auth.recommendations.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text('Recommandations IA :',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  ...auth.recommendations
                      .map((r) => _SignalRow(text: r, isRecommendation: true)),
                ],
                if (qual != null && qual.tips.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text('Conseils qualité photo :',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  ...qual.tips
                      .take(3)
                      .map((t) => _SignalRow(text: t, isRecommendation: true)),
                ],
              ],
            ],
            if (!widget.analyzed)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'En attente d\'analyse…',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SignalRow extends StatelessWidget {
  final String text;
  final bool isNegative;
  final bool isRecommendation;

  const _SignalRow({
    required this.text,
    this.isNegative = false,
    this.isRecommendation = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    if (isRecommendation) {
      color = AppColors.primary;
      icon = Icons.lightbulb_outline;
    } else if (isNegative) {
      color = AppColors.error;
      icon = Icons.circle;
    } else {
      color = AppColors.success;
      icon = Icons.check_circle_outline;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style:
                    TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
