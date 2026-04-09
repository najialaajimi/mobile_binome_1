import 'package:flutter/material.dart';
import '../../services/ai_service.dart';
import '../../utils/constants.dart';

/// Screen that shows a detailed AI text-fraud analysis for a listing's
/// title and description.
class TextFraudAnalysisScreen extends StatelessWidget {
  final String title;
  final String description;

  const TextFraudAnalysisScreen({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final analysis = AiService().analyzeTextFraud(title, description);

    Color riskColor;
    IconData riskIcon;
    String riskLabel;
    switch (analysis.riskLevel) {
      case 'high':
        riskColor = AppColors.error;
        riskIcon = Icons.dangerous_outlined;
        riskLabel = 'Risque élevé';
        break;
      case 'medium':
        riskColor = AppColors.secondary;
        riskIcon = Icons.warning_amber_outlined;
        riskLabel = 'Risque modéré';
        break;
      default:
        riskColor = AppColors.success;
        riskIcon = Icons.check_circle_outline;
        riskLabel = 'Faible risque';
    }

    final negativeSignals =
        analysis.signals.where((s) => !s.isPositive).toList();
    final positiveSignals =
        analysis.signals.where((s) => s.isPositive).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 Analyse textuelle IA'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall verdict card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [riskColor, riskColor.withAlpha(180)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(riskIcon, color: Colors.white, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    riskLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Score de suspicion : ${analysis.overallScore}/100',
                    style: TextStyle(
                        color: Colors.white.withAlpha(220), fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: analysis.overallScore / 100,
                      backgroundColor: Colors.white.withAlpha(60),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Explanation
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      size: 18, color: AppColors.primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'L\'IA analyse le texte de votre annonce pour détecter les patterns '
                      'associés aux arnaques : mots-clés suspects, coordonnées personnelles, '
                      'langage d\'urgence, manipulations émotionnelles et incohérences.',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Analyzed text preview
            const Text(
              'Texte analysé',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isNotEmpty ? title : '(Titre vide)',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 14),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      description.length > 200
                          ? '${description.substring(0, 200)}…'
                          : description,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Negative signals
            if (negativeSignals.isNotEmpty) ...[
              const Text(
                '⚠ Signaux suspects',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),
              ...negativeSignals.map((s) => _SignalCard(signal: s)),
              const SizedBox(height: 20),
            ],

            // Positive signals
            if (positiveSignals.isNotEmpty) ...[
              const Text(
                '✅ Points positifs',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),
              ...positiveSignals.map((s) => _SignalCard(signal: s)),
              const SizedBox(height: 20),
            ],

            // No signals
            if (analysis.signals.isEmpty) ...[
              const Text(
                '✅ Aucun signal suspect détecté.',
                style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 15),
              ),
              const SizedBox(height: 20),
            ],

            // Recommendations section
            const Text(
              '💡 Recommandations',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            _RecommendationCard(riskLevel: analysis.riskLevel),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _SignalCard extends StatelessWidget {
  final dynamic signal; // _TextSignal — use dynamic to avoid private access issues

  const _SignalCard({required this.signal});

  @override
  Widget build(BuildContext context) {
    final bool isPositive = signal.isPositive as bool;
    final String category = signal.category as String;
    final String description = signal.description as String;
    final int weight = signal.weight as int;

    final color = isPositive ? AppColors.success : AppColors.error;
    final bgColor = isPositive
        ? AppColors.success.withAlpha(12)
        : AppColors.error.withAlpha(12);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive ? Icons.check_circle_outline : Icons.report_outlined,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: color,
                            fontSize: 13),
                      ),
                    ),
                    if (!isPositive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '+$weight pts',
                          style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final String riskLevel;

  const _RecommendationCard({required this.riskLevel});

  @override
  Widget build(BuildContext context) {
    final List<String> tips;
    if (riskLevel == 'high') {
      tips = [
        'Réécrivez complètement votre annonce en évitant les expressions citées.',
        'Ne demandez jamais de paiement par transfert ou virement avant visite.',
        'Ne mentionnez pas vos coordonnées directement dans la description — utilisez la messagerie intégrée.',
        'Ajoutez une description détaillée du logement et de son environnement.',
        'Votre annonce risque d\'être signalée ou suspendue si ces problèmes ne sont pas corrigés.',
      ];
    } else if (riskLevel == 'medium') {
      tips = [
        'Revoyez les points signalés et corrigez-les avant de publier.',
        'Ajoutez plus de détails sur le quartier, les transports, les équipements.',
        'Assurez-vous de ne pas inclure de coordonnées dans la description.',
        'Évitez le langage d\'urgence — les locataires sérieux se méfient de la pression.',
      ];
    } else {
      tips = [
        'Votre annonce semble bien rédigée — continuez ainsi !',
        'Ajoutez des photos de qualité pour augmenter les réservations.',
        'Mentionnez les universités et transports proches pour attirer les étudiants.',
        'Un prix cohérent avec le marché augmente la visibilité de l\'annonce.',
      ];
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withAlpha(40)),
      ),
      child: Column(
        children: tips
            .map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(tip,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
