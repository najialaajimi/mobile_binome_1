import 'package:flutter/material.dart';
import '../../services/ai_service.dart';
import '../../utils/constants.dart';

class PriceSuggestionScreen extends StatefulWidget {
  const PriceSuggestionScreen({super.key});

  @override
  State<PriceSuggestionScreen> createState() => _PriceSuggestionScreenState();
}

class _PriceSuggestionScreenState extends State<PriceSuggestionScreen> {
  final _aiService = AiService();
  final _cityCtrl = TextEditingController();
  String _type = 'apartment';
  double _surface = 50;
  int _rooms = 2;
  bool _isFurnished = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _cityCtrl.dispose();
    super.dispose();
  }

  void _analyze() {
    if (_cityCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une ville.')),
      );
      return;
    }
    final result = _aiService.suggestPrice(
      city: _cityCtrl.text.trim(),
      type: _type,
      surface: _surface,
      rooms: _rooms,
      isFurnished: _isFurnished,
    );
    setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💡 Suggestion de Prix IA'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Analysez votre logement pour obtenir une estimation de prix basée sur le marché tunisien.',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 24),
            TextFormField(
              controller: _cityCtrl,
              decoration: const InputDecoration(
                labelText: 'Ville',
                prefixIcon: Icon(Icons.location_city_outlined),
                hintText: 'Ex: Tunis, Sousse, Sfax...',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _type,
              decoration:
                  const InputDecoration(labelText: 'Type de logement'),
              items: AppConstants.propertyTypeLabels.entries
                  .map((e) =>
                      DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v ?? 'apartment'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Surface : ',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text('${_surface.toInt()} m²',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: _surface,
              min: 10,
              max: 400,
              divisions: 79,
              label: '${_surface.toInt()} m²',
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _surface = v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Pièces : ',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color:
                      _rooms > 1 ? AppColors.primary : AppColors.border,
                  onPressed: _rooms > 1
                      ? () => setState(() => _rooms--)
                      : null,
                ),
                Text('$_rooms',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppColors.primary,
                  onPressed: () => setState(() => _rooms++),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Meublé',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const Spacer(),
                Switch(
                  value: _isFurnished,
                  onChanged: (v) => setState(() => _isFurnished = v),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _analyze,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Analyser'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withAlpha(15),
                      AppColors.primaryLight.withAlpha(10)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.primary.withAlpha(60)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡 Estimation IA',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        '${(_result!['suggested'] as double).toInt()} TND/mois',
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Fourchette : ${(_result!['min'] as double).toInt()} – ${(_result!['max'] as double).toInt()} TND',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _result!['explanation'] as String,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context,
                            (_result!['suggested'] as double)
                                .toInt()
                                .toString()),
                        icon: const Icon(Icons.check),
                        label: const Text('Utiliser ce prix'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
