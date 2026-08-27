import 'package:flutter/material.dart';
import '../models/kd_listing_model.dart';
import '../utils/kd_localization.dart';
import 'kd_detail_screen.dart';

class KDLeasesFeedScreen extends StatefulWidget {
  final String currentLanguage;

  const KDLeasesFeedScreen({Key? key, required this.currentLanguage})
    : super(key: key);

  @override
  State<KDLeasesFeedScreen> createState() => _KDLeasesFeedScreenState();
}

class _KDLeasesFeedScreenState extends State<KDLeasesFeedScreen> {
  late String _currentLanguage;
  late List<KDListing> _allListings;
  late List<KDListing> _filteredListings;

  String? _selectedTown;
  int? _maxBudget;
  int? _minBedrooms;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.currentLanguage;
    _allListings = KDListingMockData.sampleListings;
    _filteredListings = _allListings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.get('feed_title', language: _currentLanguage),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: InkWell(
              onTap: _showFilterDrawer,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Filter',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildFeedList(),
    );
  }

  Widget _buildFeedList() {
    if (_filteredListings.isEmpty) {
      return Center(
        child: Text(
          AppStrings.get('feed_no_results', language: _currentLanguage),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    final feedItems = <Widget>[];
    for (int i = 0; i < _filteredListings.length; i++) {
      feedItems.add(_buildListingCard(_filteredListings[i]));
      if ((i + 1) % 4 == 0) {
        feedItems.add(_buildSmartAdContainer());
      }
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: feedItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) => feedItems[index],
    );
  }

  Widget _buildListingCard(KDListing listing) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => KDDetailScreen(
              listing: listing,
              currentLanguage: _currentLanguage,
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (listing.imagePaths.isNotEmpty)
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  color: Colors.grey.shade300,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.asset(
                    listing.imagePaths.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  color: Colors.grey.shade300,
                ),
                child: const Center(
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    listing.formattedPrice,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${listing.town}, ${listing.streetName}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildAmenityChip(
                        listing.waterAvailable ? '💧 Water' : '🚫 Water',
                        listing.waterAvailable,
                      ),
                      _buildAmenityChip(
                        listing.electricityType == ElectricityType.prepaidMeter
                            ? '⚡ Prepaid'
                            : '⚡ Shared',
                        true,
                      ),
                      _buildAmenityChip(
                        listing.kitchenType == KitchenType.internalKitchen
                            ? '🍳 Internal'
                            : '🍳 External',
                        true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityChip(String label, bool isAvailable) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green.shade50 : Colors.red.shade50,
        border: Border.all(
          color: isAvailable ? Colors.green.shade200 : Colors.red.shade200,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isAvailable ? Colors.green.shade700 : Colors.red.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSmartAdContainer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        AppStrings.get('ad_safety', language: _currentLanguage),
        style: TextStyle(
          fontSize: 13,
          color: Colors.amber.shade900,
          height: 1.5,
        ),
      ),
    );
  }

  void _showFilterDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _buildFilterPanel(),
    );
  }

  Widget _buildFilterPanel() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filters',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.get('feed_filter_town', language: _currentLanguage),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTownAutocompleteFilter(),
            const SizedBox(height: 20),
            Text(
              AppStrings.get('feed_filter_budget', language: _currentLanguage),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g., 100000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                _maxBudget = int.tryParse(value);
                _applyFilters();
              },
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.get(
                'feed_filter_bedrooms',
                language: _currentLanguage,
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<int?>(
              isExpanded: true,
              value: _minBedrooms,
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(
                    AppStrings.get(
                      'feed_filter_all',
                      language: _currentLanguage,
                    ),
                  ),
                ),
                DropdownMenuItem(value: 1, child: const Text('1+')),
                DropdownMenuItem(value: 2, child: const Text('2+')),
                DropdownMenuItem(value: 3, child: const Text('3+')),
                DropdownMenuItem(value: 4, child: const Text('4+')),
              ],
              onChanged: (value) {
                setState(() {
                  _minBedrooms = value;
                  _applyFilters();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTownAutocompleteFilter() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue value) {
        final query = value.text.trim();
        if (query.isEmpty) return const Iterable<String>.empty();

        final normalized = AppStrings.normalizeTownText(query);
        final aliasMatch = AppStrings.resolveTownAlias(query);
        if (aliasMatch != null) {
          return [aliasMatch];
        }

        final matches = AppStrings.cameroonTowns.where((town) {
          final normalizedTown = AppStrings.normalizeTownText(town);
          return normalizedTown.contains(normalized) ||
              normalized.contains(normalizedTown);
        });
        return matches;
      },
      onSelected: (selection) {
        setState(() {
          _selectedTown = selection;
          _applyFilters();
        });
        Navigator.pop(context);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Yaoundé, Douala...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onChanged: (value) {
            if (value.trim().isEmpty) {
              setState(() {
                _selectedTown = null;
                _applyFilters();
              });
            }
          },
          onSubmitted: (_) => onFieldSubmitted(),
        );
      },
    );
  }

  void _applyFilters() {
    setState(() {
      _filteredListings = KDListingMockData.filterListings(
        listings: _allListings,
        town: _selectedTown,
        maxBudget: _maxBudget,
        minBedrooms: _minBedrooms,
      );
    });
  }
}
