import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/listing.dart';
import '../../services/listing_service.dart';
import '../../services/auth_service.dart';
import '../../services/ai_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _listingService = ListingService();
  final _authService = AuthService();
  final _uuid = const Uuid();

  int _currentStep = 0;
  final int _totalSteps = 5;
  bool _isLoading = false;

  // Step 1
  final _titleCtrl = TextEditingController();
  String _selectedType = 'apartment';

  // Step 2
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();

  // Step 3
  int _rooms = 2;
  int _bedrooms = 1;
  int _bathrooms = 1;
  final _surfaceCtrl = TextEditingController(text: '50');

  // Step 4
  final _priceCtrl = TextEditingController();
  DateTime? _availableFrom;
  bool _isFurnished = false;

  // Step 5
  final _descCtrl = TextEditingController();
  final List<String> _amenities = [];
  final _amenityCtrl = TextEditingController();
  final List<String> _photos = [];
  final _photoCtrl = TextEditingController();
  final List<String> _photos360 = [];
  final _photo360Ctrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    _surfaceCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _amenityCtrl.dispose();
    _photoCtrl.dispose();
    _photo360Ctrl.dispose();
    super.dispose();
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _titleCtrl.text.isNotEmpty;
      case 1:
        return _cityCtrl.text.isNotEmpty && _addressCtrl.text.isNotEmpty;
      case 2:
        return _surfaceCtrl.text.isNotEmpty;
      case 3:
        return _priceCtrl.text.isNotEmpty;
      case 4:
        return _descCtrl.text.isNotEmpty;
      default:
        return true;
    }
  }

  Future<void> _publish() async {
    setState(() => _isLoading = true);
    final ownerId = _authService.getCurrentUser()?.id ?? '';
    final listing = Listing(
      id: _uuid.v4(),
      ownerId: ownerId,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      type: _selectedType,
      city: _cityCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      postalCode: _postalCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text) ?? 0,
      rooms: _rooms,
      bedrooms: _bedrooms,
      bathrooms: _bathrooms,
      surface: double.tryParse(_surfaceCtrl.text) ?? 0,
      isFurnished: _isFurnished,
      photos: _photos,
      amenities: _amenities,
      isAvailable: true,
      availableFrom: _availableFrom ?? DateTime.now(),
      status: 'active',
      views: 0,
      createdAt: DateTime.now(),
      photos360: _photos360,
    );
    await _listingService.createListing(listing);
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Annonce publiée avec succès !'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer une annonce (${_currentStep + 1}/$_totalSteps)'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: AppColors.border,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: KeyedSubtree(
                  key: ValueKey(_currentStep),
                  child: _buildStep(),
                ),
              ),
            ),
          ),
          _buildNavButtons(),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildStep4();
      case 4:
        return _buildStep5();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text(subtitle,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Titre et type',
            'Donnez un titre accrocheur à votre annonce.'),
        TextFormField(
          controller: _titleCtrl,
          decoration: const InputDecoration(
            labelText: 'Titre de l\'annonce',
            hintText: 'Ex: Bel appartement lumineux Tunis Lac',
          ),
          maxLength: 100,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 20),
        const Text('Type de logement',
            style: TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AppConstants.propertyTypeLabels.entries.map((e) {
            final isSelected = _selectedType == e.key;
            return GestureDetector(
              onTap: () => setState(() => _selectedType = e.key),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  border: Border.all(
                    color:
                        isSelected ? AppColors.primary : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppConstants.propertyTypeIcons[e.key] ?? Icons.home,
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      e.value,
                      style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Localisation',
            'Indiquez l\'adresse exacte du logement.'),
        TextFormField(
          controller: _addressCtrl,
          decoration: const InputDecoration(
            labelText: 'Adresse',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _cityCtrl,
                decoration: const InputDecoration(labelText: 'Ville'),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _postalCtrl,
                decoration: const InputDecoration(labelText: 'Code postal'),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Caractéristiques',
            'Précisez les dimensions et pièces du logement.'),
        _buildCounter('Nombre de pièces', _rooms, (v) => setState(() => _rooms = v), 1, 20),
        const SizedBox(height: 16),
        _buildCounter('Chambres', _bedrooms, (v) => setState(() => _bedrooms = v), 0, 10),
        const SizedBox(height: 16),
        _buildCounter('Salles de bain', _bathrooms, (v) => setState(() => _bathrooms = v), 1, 5),
        const SizedBox(height: 16),
        TextFormField(
          controller: _surfaceCtrl,
          decoration: const InputDecoration(
            labelText: 'Surface (m²)',
            prefixIcon: Icon(Icons.straighten),
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Loyer et disponibilité',
            'Définissez le prix mensuel et la date de disponibilité.'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Loyer mensuel (TND)',
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.pushNamed(
                    context, AppRoutes.priceSuggestion);
                if (result != null && result is String) {
                  setState(() => _priceCtrl.text = result);
                }
              },
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: const Text('IA Prix'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
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
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.calendar_today_outlined,
              color: AppColors.primary),
          title: const Text('Date de disponibilité'),
          subtitle: Text(
            _availableFrom != null
                ? '${_availableFrom!.day}/${_availableFrom!.month}/${_availableFrom!.year}'
                : 'Immédiatement',
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) setState(() => _availableFrom = date);
          },
        ),
      ],
    );
  }

  Widget _buildStep5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Description et équipements',
            'Décrivez votre logement en détail.'),
        TextFormField(
          controller: _descCtrl,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Décrivez votre logement, son environnement...',
          ),
          maxLines: 5,
          maxLength: 1000,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        // Fraud check buttons row
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => _runFraudCheck(),
              icon: const Icon(Icons.security_outlined),
              label: const Text('Vérification IA anti-arnaque'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.textFraudAnalysis,
                arguments: {
                  'title': _titleCtrl.text,
                  'description': _descCtrl.text,
                },
              ),
              icon: const Icon(Icons.analytics_outlined),
              label: const Text('Analyse textuelle détaillée'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Équipements',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _amenityCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ajouter un équipement',
                  hintText: 'Ex: Ascenseur, Parking...',
                ),
                onSubmitted: (_) => _addAmenity(),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.add_circle, color: AppColors.primary),
              onPressed: _addAmenity,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _amenities
              .map((a) => Chip(
                    label: Text(a, style: const TextStyle(fontSize: 12)),
                    onDeleted: () =>
                        setState(() => _amenities.remove(a)),
                  ))
              .toList(),
        ),
        const SizedBox(height: 20),
        // ── Photos section ───────────────────────────────────────────
        Row(
          children: [
            const Text('Photos (URLs)',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const Spacer(),
            if (_photos.isNotEmpty)
              TextButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.photoAnalysis,
                  arguments: {'photos': List<String>.from(_photos)},
                ),
                icon: const Icon(Icons.search, size: 14),
                label: const Text('Analyser toutes (IA)',
                    style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.tips_and_updates_outlined,
                  size: 14, color: AppColors.primary),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'L\'IA vérifie l\'authenticité de chaque photo (détection GAN, images de stock, qualité).',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _photoCtrl,
                decoration: const InputDecoration(
                  labelText: 'URL de la photo',
                  hintText: 'https://...',
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.add_circle, color: AppColors.primary),
              onPressed: _addPhoto,
            ),
          ],
        ),
        ...(_photos.map((p) => ListTile(
              dense: true,
              leading: const Icon(Icons.photo_outlined),
              title: Text(p,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.search,
                        size: 16, color: AppColors.primary),
                    tooltip: 'Analyser cette photo (GAN)',
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.photoAnalysis,
                      arguments: {
                        'photos': [p]
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => setState(() => _photos.remove(p)),
                  ),
                ],
              ),
            ))),
        const SizedBox(height: 24),
        // ── 360° Photos section ──────────────────────────────────────
        Row(
          children: [
            const Icon(Icons.threed_rotation,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            const Text('Photos 360° (Visite virtuelle)',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.secondary.withAlpha(15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.panorama_outlined,
                  size: 14, color: AppColors.secondary),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Ajoutez des URLs de photos panoramiques 360° pour proposer une visite virtuelle immersive.',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.secondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _photo360Ctrl,
                decoration: const InputDecoration(
                  labelText: 'URL photo 360°',
                  hintText: 'https://... (panoramique)',
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.add_circle,
                  color: AppColors.secondary),
              onPressed: _addPhoto360,
            ),
          ],
        ),
        ...(_photos360.map((p) => ListTile(
              dense: true,
              leading: const Icon(Icons.panorama_outlined,
                  color: AppColors.secondary),
              title: Text(p,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () =>
                    setState(() => _photos360.remove(p)),
              ),
            ))),
      ],
    );
  }


  void _addAmenity() {
    if (_amenityCtrl.text.trim().isNotEmpty) {
      setState(() {
        _amenities.add(_amenityCtrl.text.trim());
        _amenityCtrl.clear();
      });
    }
  }

  void _runFraudCheck() {
    final aiService = AiService();
    final tempListing = Listing(
      id: 'temp',
      ownerId: '',
      title: _titleCtrl.text,
      description: _descCtrl.text,
      type: _selectedType,
      city: _cityCtrl.text,
      address: _addressCtrl.text,
      postalCode: _postalCtrl.text,
      price: double.tryParse(_priceCtrl.text) ?? 0,
      rooms: _rooms,
      bedrooms: _bedrooms,
      bathrooms: _bathrooms,
      surface: double.tryParse(_surfaceCtrl.text) ?? 0,
      isFurnished: _isFurnished,
      photos: _photos,
      amenities: _amenities,
      isAvailable: true,
      status: 'draft',
      createdAt: DateTime.now(),
    );
    final result = aiService.detectFraud(tempListing);
    final risk = result['risk'] as String;
    final reasons = result['reasons'] as List<String>;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              risk == 'low' ? Icons.check_circle : Icons.warning,
              color: risk == 'low' ? AppColors.success : (risk == 'high' ? AppColors.error : AppColors.secondary),
            ),
            const SizedBox(width: 8),
            Text(risk == 'low' ? 'Annonce conforme' : risk == 'high' ? 'Risque élevé détecté' : 'Points à vérifier'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reasons.isEmpty)
              const Text('Aucun problème détecté. Votre annonce semble conforme.')
            else
              ...reasons.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.circle, size: 8, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(r, style: const TextStyle(fontSize: 13))),
                      ],
                    ),
                  )),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  void _addPhoto() {
    if (_photoCtrl.text.trim().isNotEmpty) {
      setState(() {
        _photos.add(_photoCtrl.text.trim());
        _photoCtrl.clear();
      });
    }
  }

  void _addPhoto360() {
    if (_photo360Ctrl.text.trim().isNotEmpty) {
      setState(() {
        _photos360.add(_photo360Ctrl.text.trim());
        _photo360Ctrl.clear();
      });
    }
  }

  Widget _buildCounter(String label, int value, ValueChanged<int> onChanged,
      int min, int max) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          color: value > min ? AppColors.primary : AppColors.border,
          onPressed:
              value > min ? () => onChanged(value - 1) : null,
        ),
        SizedBox(
          width: 36,
          child: Center(
            child: Text(
              '$value',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          color: value < max ? AppColors.primary : AppColors.border,
          onPressed:
              value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }

  Widget _buildNavButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: Offset(0, -3))
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () =>
                    setState(() => _currentStep--),
                child: const Text('Précédent'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canProceed()
                  ? (_currentStep < _totalSteps - 1
                      ? () => setState(() => _currentStep++)
                      : _isLoading
                          ? null
                          : _publish)
                  : null,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_currentStep < _totalSteps - 1
                      ? 'Suivant'
                      : 'Publier l\'annonce'),
            ),
          ),
        ],
      ),
    );
  }
}
