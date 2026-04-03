import 'package:flutter/material.dart';
import '../../models/listing.dart';
import '../../services/listing_service.dart';
import '../../utils/constants.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/empty_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _listingService = ListingService();
  final _cityCtrl = TextEditingController();
  final _minPriceCtrl = TextEditingController();
  final _maxPriceCtrl = TextEditingController();
  final _minSurfaceCtrl = TextEditingController();
  final _maxSurfaceCtrl = TextEditingController();
  String? _selectedType;
  bool? _isFurnished;
  List<Listing> _results = [];
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    _search();
  }

  @override
  void dispose() {
    _cityCtrl.dispose();
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    _minSurfaceCtrl.dispose();
    _maxSurfaceCtrl.dispose();
    super.dispose();
  }

  void _search() {
    setState(() {
      _searched = true;
      _results = _listingService.searchListings(
        city: _cityCtrl.text.isNotEmpty ? _cityCtrl.text : null,
        minPrice: double.tryParse(_minPriceCtrl.text),
        maxPrice: double.tryParse(_maxPriceCtrl.text),
        type: _selectedType,
        minSurface: double.tryParse(_minSurfaceCtrl.text),
        maxSurface: double.tryParse(_maxSurfaceCtrl.text),
        isFurnished: _isFurnished,
      );
    });
  }

  void _resetFilters() {
    _cityCtrl.clear();
    _minPriceCtrl.clear();
    _maxPriceCtrl.clear();
    _minSurfaceCtrl.clear();
    _maxSurfaceCtrl.clear();
    setState(() {
      _selectedType = null;
      _isFurnished = null;
    });
    _search();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche avancée'),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Réinitialiser',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text(
                  '${_results.length} résultat${_results.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: _searched
                ? (_results.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off,
                        title: 'Aucun résultat',
                        message:
                            'Aucun logement ne correspond à vos critères de recherche.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _results.length,
                        itemBuilder: (_, i) =>
                            ListingCard(listing: _results[i]),
                      ))
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _cityCtrl,
            decoration: const InputDecoration(
              labelText: 'Ville ou quartier',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minPriceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Prix min (€)'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _maxPriceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Prix max (€)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildTypeChip(null, 'Tous'),
                ...AppConstants.propertyTypeLabels.entries.map(
                  (e) => _buildTypeChip(e.key, e.value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Meublé',
                  style: TextStyle(color: AppColors.textSecondary)),
              const Spacer(),
              Switch(
                value: _isFurnished ?? false,
                onChanged: (v) =>
                    setState(() => _isFurnished = v ? true : null),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _search,
              icon: const Icon(Icons.search),
              label: const Text('Rechercher'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String? type, String label) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedType = type);
        _search();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
