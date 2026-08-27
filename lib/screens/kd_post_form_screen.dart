import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/kd_listing_model.dart';
import '../utils/kd_localization.dart';
import 'kd_confirmation_screen.dart';

class KDPostFormScreen extends StatefulWidget {
  final FeedCategory initialCategory; // Enforce natural language supply targets
  final UserRole initialRole; // Tenant vs Landlord boundary routing flags
  final String currentLanguage;

  const KDPostFormScreen({
    Key? key,
    required this.initialCategory,
    required this.initialRole,
    required this.currentLanguage,
  }) : super(key: key);

  @override
  State<KDPostFormScreen> createState() => _KDPostFormScreenState();
}

class _KDPostFormScreenState extends State<KDPostFormScreen> {
  late final String _currentLanguage;

  // Controllers
  late final TextEditingController _rentController;
  late final TextEditingController _townController;
  late final TextEditingController
  _streetNameController; // Treated as "Quarter" per UX
  late final TextEditingController _descriptionController;

  DateTime? _leavingDate;
  bool _waterAvailable = true;
  ElectricityType _electricityType = ElectricityType.prepaidMeter;
  KitchenType _kitchenType = KitchenType.internalKitchen;
  List<String> _selectedImagePaths = [];

  // Roommate track parameters
  String _genderPreference = 'Open to All';
  Set<String> _targetAgeRanges = {};
  Set<String> _lifestyleTags = {};
  String _expectedDuration = 'Flexible/Negotiable';

  // Strict numeric counting parameters
  int _selectedBedroomCount = 1;

  // Anti-fraud status track metrics
  bool _isListingLimitExceeded = false;
  bool _isEditMode =
      false; // Toggle flag to handle freezing logic when refactoring active ads

  // Mock geo-coordinates for Cameroon sandbox testing
  final double _mockLatitude = 3.8480;
  final double _mockLongitude = 11.5021;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.currentLanguage;
    _rentController = TextEditingController();
    _townController = TextEditingController();
    _streetNameController = TextEditingController();
    _descriptionController = TextEditingController();
    _leavingDate = DateTime.now().add(const Duration(days: 30));

    _verifyListingCeilingLimit();
  }

  @override
  void dispose() {
    _rentController.dispose();
    _townController.dispose();
    _streetNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// 4.5 2-Listing Ceiling Verification Loop
  /// Checks system database state parameters. Blocks forms if users game slot constraints.
  void _verifyListingCeilingLimit() {
    // Look up mock registry tracking data arrays
    final userActivePostsCount = KDListingMockData.sampleListings
        .where(
          (listing) => listing.userId == 'current_user' && !listing.isExpired,
        )
        .length;

    if (userActivePostsCount >= 2 && !_isEditMode) {
      setState(() {
        _isListingLimitExceeded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Block access if middleman capacity limits are breached
    if (_isListingLimitExceeded) {
      return _buildCeilingBlockWarningScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.get('form_title', language: _currentLanguage),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dynamic form generation mapped specifically to role configuration routing matrices
              if (widget.initialCategory == FeedCategory.tenant)
                _buildLeavingTenantForm()
              else if (widget.initialCategory == FeedCategory.roommate)
                _buildHostRoommateForm()
              else if (widget.initialCategory == FeedCategory.hotel ||
                  widget.initialCategory == FeedCategory.guesthouse)
                _buildPropertyOwnerVacancyForm(),
            ],
          ),
        ),
      ),
    );
  }

  /// 4.5 The Ceiling Limit Enforcement Screen Template Layout
  Widget _buildCeilingBlockWarningScreen() {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Limit Reached')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.gpp_bad_rounded, color: Colors.red, size: 64),
            const SizedBox(height: 20),
            Text(
              _currentLanguage == AppStrings.EN
                  ? 'Active Listing Limit Reached'
                  : 'Limite d\'annonces actives atteinte',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _currentLanguage == AppStrings.EN
                  ? 'You are already hosting 2 active listings. Please delete or mark 1 as resolved to upload a new one.'
                  : 'Vous gérez déjà 2 annonces actives. Veuillez en supprimer ou en résoudre 1 pour en publier une nouvelle.',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Form 1: Outgoing Tenant Relocation Lease Transfer Form
  Widget _buildLeavingTenantForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCurrencyField(
          controller: _rentController,
          label: AppStrings.get('form_rent_label', language: _currentLanguage),
          hint: 'e.g., 75000',
        ),
        const SizedBox(height: 16),
        _buildTownAutocompleteField(),
        const SizedBox(height: 16),
        _buildQuarterTextField(
          controller: _streetNameController,
          label: _currentLanguage == AppStrings.EN ? 'Quarter' : 'Quartier',
          hint: 'e.g., Bastos, Biyem-Assi',
        ),
        const SizedBox(height: 16),
        _buildBedroomDropdownSelector(),
        const SizedBox(height: 16),
        _buildDatePickerField(
          label: AppStrings.get(
            'form_leaving_date_label',
            language: _currentLanguage,
          ),
          selectedDate: _leavingDate,
          onDateSelected: (date) => setState(() => _leavingDate = date),
        ),
        const SizedBox(height: 16),
        _buildToggleField(
          label: AppStrings.get('form_water_label', language: _currentLanguage),
          value: _waterAvailable,
          onChanged: (value) => setState(() => _waterAvailable = value),
        ),
        const SizedBox(height: 16),
        _buildElectricitySelector(),
        const SizedBox(height: 16),
        _buildKitchenSelector(),
        const SizedBox(height: 16),
        _buildDescriptionBoxField(),
        const SizedBox(height: 24),
        _buildPhotoUploadSection(),
        const SizedBox(height: 24),
        _buildSubmitButtons(),
      ],
    );
  }

  /// Form 2: Active Resident Bill Split/Roommate Co-Hosting Form
  Widget _buildHostRoommateForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCurrencyField(
          controller: _rentController,
          label: _currentLanguage == AppStrings.EN
              ? 'Total Apartment Rent'
              : 'Loyer total de l\'appartement',
          hint: 'e.g., 150000',
        ),
        const SizedBox(height: 16),
        _buildTownAutocompleteField(),
        const SizedBox(height: 16),
        _buildQuarterTextField(
          controller: _streetNameController,
          label: _currentLanguage == AppStrings.EN ? 'Quarter' : 'Quartier',
          hint: 'e.g., Molyko, Bonamoussadi',
        ),
        const SizedBox(height: 16),
        _buildBedroomDropdownSelector(),
        const SizedBox(height: 24),
        Text(
          _currentLanguage == AppStrings.EN
              ? 'Roommate Preferences'
              : 'Compatibilité des Colocataires',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 16),
        _buildGenderGroupSelector(),
        const SizedBox(height: 16),
        _buildAgeGroupCheckboxGroup(),
        const SizedBox(height: 16),
        _buildLifestyleTagsCheckboxGroup(),
        const SizedBox(height: 16),
        _buildDurationRadioGroup(),
        const SizedBox(height: 16),
        _buildDescriptionBoxField(),
        const SizedBox(height: 24),
        _buildPhotoUploadSection(),
        const SizedBox(height: 24),
        _buildSubmitButtons(),
      ],
    );
  }

  /// Form 3: Property Owner Commercial/Airbnb Vacant Lodging Form
  Widget _buildPropertyOwnerVacancyForm() {
    final isHotel = widget.initialCategory == FeedCategory.hotel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCurrencyField(
          controller: _rentController,
          label: isHotel
              ? (_currentLanguage == AppStrings.EN
                    ? 'Daily Rate'
                    : 'Tarif journalier')
              : AppStrings.get('form_rent_label', language: _currentLanguage),
          hint: 'e.g., 30000',
        ),
        const SizedBox(height: 16),
        _buildTownAutocompleteField(),
        const SizedBox(height: 16),
        _buildQuarterTextField(
          controller: _streetNameController,
          label: _currentLanguage == AppStrings.EN
              ? 'Quarter Location'
              : 'Quartier de l\'immeuble',
          hint: 'e.g., Plage Ngoye, Bastos',
        ),
        const SizedBox(height: 16),
        _buildBedroomDropdownSelector(),
        const SizedBox(height: 16),
        _buildToggleField(
          label: AppStrings.get('form_water_label', language: _currentLanguage),
          value: _waterAvailable,
          onChanged: (value) => setState(() => _waterAvailable = value),
        ),
        const SizedBox(height: 16),
        _buildElectricitySelector(),
        const SizedBox(height: 16),
        _buildKitchenSelector(),
        const SizedBox(height: 16),
        _buildDescriptionBoxField(),
        const SizedBox(height: 24),
        _buildPhotoUploadSection(),
        const SizedBox(height: 24),
        _buildSubmitButtons(),
      ],
    );
  }

  Widget _buildQuarterTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          // 4.7 Location Freeze: Blocks character updates if the ad slot is currently in modification view
          readOnly: _isEditMode,
          decoration: InputDecoration(
            hintText: hint,
            fillColor: _isEditMode ? Colors.grey.shade100 : null,
            filled: _isEditMode,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildBedroomDropdownSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _currentLanguage == AppStrings.EN
              ? 'Number of Bedrooms'
              : 'Nombre de chambres',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _selectedBedroomCount,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          items: const [
            DropdownMenuItem(value: 1, child: Text('1 Room / Studio')),
            DropdownMenuItem(value: 2, child: Text('2 Rooms')),
            DropdownMenuItem(value: 3, child: Text('3 Rooms')),
            DropdownMenuItem(value: 4, child: Text('4+ Rooms')),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _selectedBedroomCount = val);
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionBoxField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get('form_description_label', language: _currentLanguage),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: AppStrings.get(
              'form_description_hint',
              language: _currentLanguage,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppStrings.get('form_rent_suffix', language: _currentLanguage),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTownAutocompleteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get('form_town_label', language: _currentLanguage),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue value) {
            if (_isEditMode)
              return const Iterable.empty(); // Fully lock suggestions under edit mode checks
            final query = value.text.trim();
            if (query.isEmpty) return const Iterable.empty();
            final resolvedAlias = AppStrings.resolveTownAlias(query);
            if (resolvedAlias != null) return [resolvedAlias];

            return AppStrings.cameroonTowns.where((town) {
              return AppStrings.normalizeTownText(
                town,
              ).contains(AppStrings.normalizeTownText(query));
            });
          },
          onSelected: (selection) => _townController.text = selection,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            if (controller.text.isEmpty && _townController.text.isNotEmpty) {
              controller.text = _townController.text;
            }
            return TextField(
              controller: controller,
              focusNode: focusNode,
              readOnly: _isEditMode, // 4.7 Lock immutable location parameters
              decoration: InputDecoration(
                hintText: AppStrings.get(
                  'form_town_hint',
                  language: _currentLanguage,
                ),
                fillColor: _isEditMode ? Colors.grey.shade100 : null,
                filled: _isEditMode,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (val) => _townController.text = val,
              onSubmitted: (_) => onFieldSubmitted(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) onDateSelected(picked);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                      : 'Select date',
                ),
                const Icon(Icons.calendar_today_rounded),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleField({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blue.shade700,
        ),
      ],
    );
  }

  Widget _buildElectricitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get('form_electricity_label', language: _currentLanguage),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        RadioListTile<ElectricityType>(
          title: Text(
            AppStrings.get(
              'form_electricity_prepaid',
              language: _currentLanguage,
            ),
          ),
          value: ElectricityType.prepaidMeter,
          groupValue: _electricityType,
          onChanged: (val) {
            if (val != null) setState(() => _electricityType = val);
          },
        ),
        RadioListTile<ElectricityType>(
          title: Text(
            AppStrings.get(
              'form_electricity_shared',
              language: _currentLanguage,
            ),
          ),
          value: ElectricityType.sharedMeter,
          groupValue: _electricityType,
          onChanged: (val) {
            if (val != null) setState(() => _electricityType = val);
          },
        ),
      ],
    );
  }

  Widget _buildKitchenSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get('form_kitchen_label', language: _currentLanguage),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        RadioListTile<KitchenType>(
          title: Text(
            AppStrings.get('form_kitchen_internal', language: _currentLanguage),
          ),
          value: KitchenType.internalKitchen,
          groupValue: _kitchenType,
          onChanged: (val) {
            if (val != null) setState(() => _kitchenType = val);
          },
        ),
        RadioListTile<KitchenType>(
          title: Text(
            AppStrings.get('form_kitchen_external', language: _currentLanguage),
          ),
          value: KitchenType.sharedKitchen,
          groupValue: _kitchenType,
          onChanged: (val) {
            if (val != null) setState(() => _kitchenType = val);
          },
        ),
      ],
    );
  }

  Widget _buildGenderGroupSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get(
            'host_form_gender_pref_label',
            language: _currentLanguage,
          ),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        ...['Open to All', 'Males Only', 'Females Only'].map(
          (gender) => RadioListTile<String>(
            title: Text(gender),
            value: gender,
            groupValue: _genderPreference,
            onChanged: (val) {
              if (val != null) setState(() => _genderPreference = val);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAgeGroupCheckboxGroup() {
    final options = ['<20', '20s', '30s', '40s', '50+'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get(
            'host_form_target_age_label',
            language: _currentLanguage,
          ),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Wrap(
          spacing: 8,
          children: options
              .map(
                (age) => FilterChip(
                  label: Text(age),
                  selected: _targetAgeRanges.contains(age),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _targetAgeRanges.add(age);
                      } else {
                        _targetAgeRanges.remove(age);
                      }
                    });
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildLifestyleTagsCheckboxGroup() {
    final options = ['No Smoking', 'No Pets', 'Quiet Space'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get(
            'host_form_lifestyle_label',
            language: _currentLanguage,
          ),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Wrap(
          spacing: 8,
          children: options
              .map(
                (tag) => FilterChip(
                  label: Text(tag),
                  selected: _lifestyleTags.contains(tag),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _lifestyleTags.add(tag);
                      } else {
                        _lifestyleTags.remove(tag);
                      }
                    });
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDurationRadioGroup() {
    final options = [
      'Flexible/Negotiable',
      'Short term: 1-3 months',
      'Medium term: 6 months',
      'Long term: 1 year+',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get(
            'host_form_duration_label',
            language: _currentLanguage,
          ),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        ...options.map(
          (duration) => RadioListTile<String>(
            title: Text(duration),
            value: duration,
            groupValue: _expectedDuration,
            onChanged: (val) {
              if (val != null) setState(() => _expectedDuration = val);
            },
          ),
        ),
      ],
    );
  }

  /// 4.6 CAMERA-ONLY PLUG MEDIA LOCK
  /// Strips photo library options out completely to defeat stock image fraud loops
  Widget _buildPhotoUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get('form_photos_label', language: _currentLanguage),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            ...List.generate(
              _selectedImagePaths.length,
              (index) => _buildPhotoBox(index),
            ),
            if (_selectedImagePaths.length < 3)
              InkWell(
                onTap: _captureLiveCameraPicture,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 32,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.getWithParams('form_photos_count', {
            'count': _selectedImagePaths.length.toString(),
          }, language: _currentLanguage),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPhotoBox(int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(File(_selectedImagePaths[index])),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => setState(() => _selectedImagePaths.removeAt(index)),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 4.6 Strict Live Camera Capture Trigger
  Future<void> _captureLiveCameraPicture() async {
    if (_selectedImagePaths.length >= 3) return;

    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: ImageSource
            .camera, // Gallery option completely dropped to eliminate stock photo gaming
        maxWidth: 1600,
        imageQuality: 80,
      );

      if (picked != null) {
        setState(() {
          _selectedImagePaths.add(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera capture failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSubmitButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _executeFormValidationSubmission,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              AppStrings.get('form_submit', language: _currentLanguage),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              AppStrings.get('form_cancel', language: _currentLanguage),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  void _executeFormValidationSubmission() {
    if (_rentController.text.isEmpty ||
        _townController.text.isEmpty ||
        _streetNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('error', language: _currentLanguage)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Assemble robust target listing node injection mapping out physical coordinates parameters
    final listing = KDListing(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: widget.initialCategory,
      rentPrice: int.tryParse(_rentController.text) ?? 0,
      town: _townController.text,
      streetName: _streetNameController.text,
      leavingByDate: _leavingDate ?? DateTime.now(),
      imagePaths: _selectedImagePaths,
      waterAvailable: _waterAvailable,
      electricityType: _electricityType,
      kitchenType: _kitchenType,
      generalDescription: _descriptionController.text,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(
        const Duration(days: 30),
      ), // Enforces explicit 30 days expiration rule block
      userId: 'current_user',
      bedroomCount: _selectedBedroomCount,
      postedByRole:
          widget.initialRole, // Attaches the authenticated role cleanly
      latitude:
          _mockLatitude, // Injects stationary anti-fraud location parameters
      longitude: _mockLongitude,
      hasLiveAd:
          widget.initialRole ==
          UserRole
              .tenant, // Landlord posts go to draft pending mobile money checkout loop
    );

    // If it's a Landlord/Hotel posting vacancy, intercept layout and route to MoMo Checkout statement logs mock here
    debugPrint(
      'Listing payload created successfully for verification: ${listing.toString()}',
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => KDConfirmationScreen(currentLanguage: _currentLanguage),
      ),
      (route) => route.isFirst,
    );
  }
}
