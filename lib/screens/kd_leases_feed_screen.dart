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

  // Track multi-selected categories for the quick top filter ribbon
  final List<FeedCategory> _selectedCategories = [];

  String? _selectedTown;
  int? _maxBudget;
  int? _exactRoomCount;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.currentLanguage;
    _allListings = KDListingMockData.sampleListings;
  }

  /// Toggles selection of a category chip from the top navigation ribbon
  void _toggleCategory(FeedCategory category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedTown = null;
      _maxBudget = null;
      _exactRoomCount = null;
      _selectedCategories.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredListings = KDListingMockData.filterListings(
      listings: _allListings,
      activeCategories: _selectedCategories,
      town: _selectedTown,
      maxBudget: _maxBudget,
      exactRoomCount: _exactRoomCount,
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          AppStrings.get('feed_title', language: _currentLanguage),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: _buildTopCategoryRibbon(),
        ),
      ),
      body: _buildResponsiveGrid(filteredListings),
    );
  }

  /// Top 4-Button Category Filter Bar Horizontal Ribbon
  Widget _buildTopCategoryRibbon() {
    return Container(
      height: 56.0,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      color: Theme.of(context).canvasColor,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: FeedCategory.values.map((category) {
          final isSelected = _selectedCategories.contains(category);

          String label = '';
          switch (category) {
            case FeedCategory.tenant:
              label = _currentLanguage == AppStrings.en ? 'Tenant' : 'Locataire';
              break;
            case FeedCategory.roommate:
              label = _currentLanguage == AppStrings.en ? 'Roommate' : 'Colocataire';
              break;
            case FeedCategory.hotel:
              label = _currentLanguage == AppStrings.en ? 'Hotel' : 'Hôtel';
              break;
            case FeedCategory.guesthouse:
              label = _currentLanguage == AppStrings.en ? 'Guesthouse' : 'Résidence';
              break;
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => _toggleCategory(category),
              selectedColor: Colors.blue.shade700,
              checkmarkColor: Colors.white,
              backgroundColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Responsive Multi-Column Grid Builder Layout
  Widget _buildResponsiveGrid(List<KDListing> listings) {
    if (listings.isEmpty) {
      return Center(
        child: Text(
          AppStrings.get('feed_no_results', language: _currentLanguage),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int columnsCount = (constraints.maxWidth / 180).floor();
        if (columnsCount < 2) columnsCount = 2;

        return GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnsCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.72,
          ),
          itemCount: listings.length,
          itemBuilder: (context, index) {
            final item = listings[index];
            return _buildMarketplaceCard(item);
          },
        );
      },
    );
  }

  /// Minimalist Item Grid Display Card
  Widget _buildMarketplaceCard(KDListing listing) {
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
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: listing.category == FeedCategory.roommate
            ? Colors.blue.shade50.withOpacity(0.3)
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      color: Colors.grey.shade300,
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.asset(
                        listing.imagePaths.isNotEmpty
                            ? listing.imagePaths.first
                            : 'assets/fallback.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(Icons.image_not_supported, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (listing.postedByRole == UserRole.landlord || listing.isOwnerVerified)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade700,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.verified_user_rounded, size: 10, color: Colors.white),
                            SizedBox(width: 2),
                            Text(
                              'Owner',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (listing.category == FeedCategory.roommate)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.handshake_rounded, size: 12, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.formattedPrice,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${listing.town}, ${listing.streetName}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${listing.bedroomCount} BR',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        listing.freshnessLabel,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDrawer() {
    showModalBottomSheet
      context: context,
      isScrollControlled: true, // Handle layout adjustments alongside keyboard
      backgroundColor: Colors.transparent,
      builder: (_) => _buildFilterPanel(),
    );
  }

  /// Fixed filter sheet frame: solves keyboard obscurity loops natively
  Widget _buildFilterPanel() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    TextButton(
                      onPressed: () {
                        _clearAllFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Town autocomplete field
                Text(
                  AppStrings.get('feed_filter_town', language: _currentLanguage),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildTownAutocompleteFilter(setModalState),
                const SizedBox(height: 16),

                // Rent budget target field
                Text(
                  AppStrings.get('feed_filter_budget', language: _currentLanguage),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g., 75000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  onChanged: (value) {
                    _maxBudget = int.tryParse(value);
                    _applyFilters();
                  },
                ),
                const SizedBox(height: 16),

                // Bedroom count dropdown
                Text(
                  AppStrings.get('feed_filter_bedrooms', language: _currentLanguage),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int?>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                  ),
                  isExpanded: true,
                  value: _exactRoomCount,
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(
                        AppStrings.get('feed_filter_all', language: _currentLanguage),
                      ),
                    ),
                    const DropdownMenuItem(value: 1, child: Text('1 Room')),
                    const DropdownMenuItem(value: 2, child: Text('2 Rooms')),
                    const DropdownMenuItem(value: 3, child: Text('3 Rooms')),
                    const DropdownMenuItem(value: 4, child: Text('4+ Rooms')),
                  ],
                  onChanged: (value) {
                    setModalState(() {
                      _exactRoomCount = value;
                    });
                    _applyFilters();
                  },
                ),
                const SizedBox(height: 24),

                // Final apply button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Apply Changes',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTownAutocompleteFilter(StateSetter setModalState) {
    return Autocomplete(
      optionsBuilder: (TextEditingValue textEditingValue) {
        final query = textEditingValue.text.trim();
        if (query.isEmpty) return const Iterable.empty();

        final normalized = AppStrings.normalizeTownText(query);
        final aliasMatch = AppStrings.resolveTownAlias(query);
        if (aliasMatch != null) return [aliasMatch];

        return AppStrings.cameroonTowns.where((town) {
          final normalizedTown = AppStrings.normalizeTownText(town);
          return normalizedTown.contains(normalized) ||
              normalized.contains(normalizedTown);
        });
      },
      onSelected: (selection) {
        setModalState(() {
          _selectedTown = selection;
        });
        _applyFilters();
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        if (_selectedTown != null && controller.text.isEmpty) {
          controller.text = _selectedTown!;
        }
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Yaoundé, Douala, Buéa...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      controller.clear();
                      setModalState(() {
                        _selectedTown = null;
                      });
                      _applyFilters();
                    },
                  )
                : null,
          ),
          onSubmitted: (_) => onFieldSubmitted(),
        );
      },
    );
  }

  void _applyFilters() {
    setState(() {}); // Triggers rebuild with active filters
  }
}
