import 'package:flutter/material.dart';
import '../../models/user_preferences.dart';
import '../../services/ai_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final _aiService = AiService();
  final _authService = AuthService();

  double _budgetMin = 0;
  double _budgetMax = 2000;
  final List<String> _preferredTypes = [];
  String _lifestyle = 'any';
  bool _isStudent = false;
  String _studyField = 'autre';
  String _nearUniversity = 'any';
  String _preferredLanguage = 'fr';
  final _nationalityCtrl = TextEditingController();
  int _leaseDuration = 6;
  bool? _wantFurnished;
  int _minRooms = 1;
  // New IA roommate-matching fields
  String _schedule = 'flexible';
  int _cleanlinessLevel = 3;
  bool _smokingAllowed = false;
  bool _petsAllowed = false;
  final List<String> _hobbies = [];
  final _bioCtrl = TextEditingController();

  static const _tunisianUniversities = [
    'any',
    'Université de Tunis',
    'ESPRIT',
    'Université de Sousse',
    'INSAT',
    'Université de Sfax',
    'ISET Tunis',
    'Université de Carthage',
    'ISG Tunis',
    'Université de Monastir',
    'Université de Bizerte',
  ];

  static const _studyFields = [
    'informatique',
    'médecine',
    'ingénierie',
    'lettres',
    'droit',
    'économie',
    'architecture',
    'autre'
  ];

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  void _loadExisting() {
    final userId = _authService.getCurrentUser()?.id ?? '';
    final prefs = _aiService.getUserPreferences(userId);
    if (prefs != null) {
      setState(() {
        _budgetMin = prefs.budgetMin ?? 0;
        _budgetMax = prefs.budgetMax ?? 2000;
        _preferredTypes.addAll(prefs.preferredTypes);
        _lifestyle = prefs.lifestyle;
        _isStudent = prefs.isStudent;
        _studyField =
            prefs.studyField.isNotEmpty ? prefs.studyField : 'autre';
        _nearUniversity = prefs.nearUniversity;
        _preferredLanguage = prefs.preferredLanguage;
        _nationalityCtrl.text = prefs.nationality;
        _leaseDuration = prefs.leaseDurationMonths;
        _wantFurnished = prefs.wantFurnished;
        _minRooms = prefs.minRooms ?? 1;
        _schedule = prefs.schedule;
        _cleanlinessLevel = prefs.cleanlinessLevel;
        _smokingAllowed = prefs.smokingAllowed;
        _petsAllowed = prefs.petsAllowed;
        _hobbies.clear();
        _hobbies.addAll(prefs.hobbies);
        _bioCtrl.text = prefs.bio;
      });
    }
  }

  @override
  void dispose() {
    _nationalityCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final userId = _authService.getCurrentUser()?.id ?? '';
    if (userId.isEmpty) return;
    final prefs = UserPreferences(
      userId: userId,
      budgetMin: _budgetMin > 0 ? _budgetMin : null,
      budgetMax: _budgetMax < 2000 ? _budgetMax : null,
      preferredTypes: List.from(_preferredTypes),
      lifestyle: _lifestyle,
      isStudent: _isStudent,
      studyField: _isStudent ? _studyField : '',
      nearUniversity: _nearUniversity,
      preferredLanguage: _preferredLanguage,
      nationality: _nationalityCtrl.text.trim(),
      minRooms: _minRooms > 1 ? _minRooms : null,
      maxRooms: null,
      minSurface: null,
      wantFurnished: _wantFurnished,
      leaseDurationMonths: _leaseDuration,
      searchHistory: _aiService.getViewHistory(userId),
      schedule: _schedule,
      cleanlinessLevel: _cleanlinessLevel,
      smokingAllowed: _smokingAllowed,
      petsAllowed: _petsAllowed,
      hobbies: List.from(_hobbies),
      bio: _bioCtrl.text.trim(),
    );
    await _aiService.saveUserPreferences(prefs);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Préférences sauvegardées !'),
            backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Préférences'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('💰 Budget mensuel (TND)'),
            Row(
              children: [
                Text('${_budgetMin.toInt()} TND',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Expanded(
                  child: RangeSlider(
                    values: RangeValues(_budgetMin, _budgetMax),
                    min: 0,
                    max: 3000,
                    divisions: 60,
                    labels: RangeLabels(
                        '${_budgetMin.toInt()}', '${_budgetMax.toInt()}'),
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() {
                      _budgetMin = v.start;
                      _budgetMax = v.end;
                    }),
                  ),
                ),
                Text('${_budgetMax.toInt()} TND',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 20),
            _sectionTitle('🏠 Type de logement'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.propertyTypeLabels.entries.map((e) {
                final selected = _preferredTypes.contains(e.key);
                return FilterChip(
                  label: Text(e.value),
                  selected: selected,
                  selectedColor: AppColors.primary.withAlpha(30),
                  checkmarkColor: AppColors.primary,
                  onSelected: (v) => setState(() {
                    if (v) {
                      _preferredTypes.add(e.key);
                    } else {
                      _preferredTypes.remove(e.key);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _sectionTitle('🎵 Style de vie'),
            Row(
              children: [
                _radioChip('Calme', 'calme', _lifestyle,
                    (v) => setState(() => _lifestyle = v)),
                const SizedBox(width: 12),
                _radioChip('Animé', 'anime', _lifestyle,
                    (v) => setState(() => _lifestyle = v)),
                const SizedBox(width: 12),
                _radioChip('Peu importe', 'any', _lifestyle,
                    (v) => setState(() => _lifestyle = v)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _sectionTitle('🎓 Étudiant(e)'),
                const Spacer(),
                Switch(
                  value: _isStudent,
                  onChanged: (v) => setState(() => _isStudent = v),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            if (_isStudent) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _studyField,
                decoration:
                    const InputDecoration(labelText: 'Domaine d\'études'),
                items: _studyFields
                    .map((f) => DropdownMenuItem(
                        value: f, child: Text(_capitalize(f))))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _studyField = v ?? 'autre'),
              ),
            ],
            const SizedBox(height: 20),
            _sectionTitle('🏛️ Université proche'),
            DropdownButtonFormField<String>(
              value: _nearUniversity,
              decoration:
                  const InputDecoration(labelText: 'Université'),
              items: _tunisianUniversities
                  .map((u) => DropdownMenuItem(
                      value: u,
                      child: Text(u == 'any' ? 'Peu importe' : u)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _nearUniversity = v ?? 'any'),
            ),
            const SizedBox(height: 20),
            _sectionTitle('🌍 Langue préférée'),
            Row(
              children: [
                _radioChip('Français', 'fr', _preferredLanguage,
                    (v) => setState(() => _preferredLanguage = v)),
                const SizedBox(width: 12),
                _radioChip('English', 'en', _preferredLanguage,
                    (v) => setState(() => _preferredLanguage = v)),
                const SizedBox(width: 12),
                _radioChip('Arabe', 'ar', _preferredLanguage,
                    (v) => setState(() => _preferredLanguage = v)),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nationalityCtrl,
              decoration: const InputDecoration(
                labelText: 'Nationalité',
                prefixIcon: Icon(Icons.flag_outlined),
                hintText: 'Ex: Tunisien, Français, Sénégalais...',
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle('📅 Durée de bail souhaitée'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [1, 3, 6, 12].map((m) {
                final label = m == 1 ? '1 mois' : '$m mois';
                return ChoiceChip(
                  label: Text(label),
                  selected: _leaseDuration == m,
                  selectedColor: AppColors.primary.withAlpha(30),
                  onSelected: (v) {
                    if (v) setState(() => _leaseDuration = m);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _sectionTitle('🛋️ Meublé'),
                const Spacer(),
                DropdownButton<bool?>(
                  value: _wantFurnished,
                  items: const [
                    DropdownMenuItem(
                        value: null, child: Text('Peu importe')),
                    DropdownMenuItem(
                        value: true, child: Text('Oui, meublé')),
                    DropdownMenuItem(
                        value: false, child: Text('Non meublé')),
                  ],
                  onChanged: (v) => setState(() => _wantFurnished = v),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _sectionTitle('🚪 Nombre de pièces minimum'),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: _minRooms > 1
                      ? AppColors.primary
                      : AppColors.border,
                  onPressed: _minRooms > 1
                      ? () => setState(() => _minRooms--)
                      : null,
                ),
                Text('$_minRooms',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: _minRooms < 10
                      ? AppColors.primary
                      : AppColors.border,
                  onPressed: _minRooms < 10
                      ? () => setState(() => _minRooms++)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 32),
            // ── New IA compatibility fields ──────────────────────────
            _sectionTitle('⏰ Rythme de vie'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _radioChip('Lève-tôt', 'morning', _schedule,
                    (v) => setState(() => _schedule = v)),
                _radioChip('Soir', 'evening', _schedule,
                    (v) => setState(() => _schedule = v)),
                _radioChip('Noctambule', 'night', _schedule,
                    (v) => setState(() => _schedule = v)),
                _radioChip('Flexible', 'flexible', _schedule,
                    (v) => setState(() => _schedule = v)),
              ],
            ),
            const SizedBox(height: 20),
            _sectionTitle('🧹 Niveau de propreté ($_cleanlinessLevel/5)'),
            Slider(
              value: _cleanlinessLevel.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: _cleanlinessLabel(_cleanlinessLevel),
              activeColor: AppColors.primary,
              onChanged: (v) =>
                  setState(() => _cleanlinessLevel = v.round()),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _sectionTitle('🚬 Fumeur(se)'),
                const Spacer(),
                Switch(
                  value: _smokingAllowed,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _smokingAllowed = v),
                ),
              ],
            ),
            Row(
              children: [
                _sectionTitle('🐾 Animaux acceptés'),
                const Spacer(),
                Switch(
                  value: _petsAllowed,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _petsAllowed = v),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _sectionTitle('🎯 Centres d\'intérêt'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allHobbies.map((h) {
                final selected = _hobbies.contains(h);
                return FilterChip(
                  label: Text(h),
                  selected: selected,
                  selectedColor: AppColors.secondary.withAlpha(30),
                  checkmarkColor: AppColors.secondary,
                  onSelected: (v) => setState(() {
                    if (v) {
                      _hobbies.add(h);
                    } else {
                      _hobbies.remove(h);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _sectionTitle('✍️ Bio / Présentation'),
            TextField(
              controller: _bioCtrl,
              maxLines: 3,
              maxLength: 200,
              decoration: const InputDecoration(
                hintText: 'Décrivez-vous brièvement pour trouver un bon colocataire…',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Sauvegarder mes préférences'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
      );

  Widget _radioChip(String label, String value, String current,
          ValueChanged<String> onChanged) =>
      GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: current == value ? AppColors.primary : Colors.white,
            border: Border.all(
                color: current == value
                    ? AppColors.primary
                    : AppColors.border),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label,
              style: TextStyle(
                  color: current == value
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontSize: 13)),
        ),
      );

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _cleanlinessLabel(int level) {
    switch (level) {
      case 1:
        return 'Très décontracté';
      case 2:
        return 'Décontracté';
      case 3:
        return 'Normal';
      case 4:
        return 'Très propre';
      case 5:
        return 'Impeccable';
      default:
        return '$level';
    }
  }

  static const _allHobbies = [
    'Sport',
    'Musique',
    'Cinéma',
    'Cuisine',
    'Jeux vidéo',
    'Lecture',
    'Voyages',
    'Art',
    'Yoga',
    'Nature',
    'Danse',
    'Photo',
  ];
}
