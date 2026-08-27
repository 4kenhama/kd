import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/kd_listing_model.dart';
import '../utils/kd_localization.dart';
import 'kd_confirmation_screen.dart';

class KDPostFormScreen extends StatefulWidget {
  final String selectedChoice;
  final String currentLanguage;

  const KDPostFormScreen({
    Key? key,
    required this.selectedChoice,
    required this.currentLanguage,
  }) : super(key: key);

  @override
  State<KDPostFormScreen> createState() => _KDPostFormScreenState();
}

class _KDPostFormScreenState extends State<KDPostFormScreen> {
  late final String _currentLanguage;
  late final TextEditingController _titleController;
  late final TextEditingController _rentController;
  late final TextEditingController _townController;
  late final TextEditingController _streetNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _aliasController;
  late final TextEditingController _preferredstreetNameController;

  DateTime? _leavingDate;
  bool _waterAvailable = true;
  ElectricityType _electricityType = ElectricityType.prepaidMeter;
  KitchenType _kitchenType = KitchenType.internalKitchen;
  List<String> _selectedImagePaths = [];

  // For "looking for room" track
  String _ageRange = '<20';

  // For "host" track
  String _genderPreference = 'Open to All';
  Set<String> _targetAgeRanges = {};
  Set<String> _lifestyleTags = {};
  String _expectedDuration = 'Flexible/Negotiable';

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.currentLanguage;
    _titleController = TextEditingController();
    _rentController = TextEditingController();
    _townController = TextEditingController();
    _streetNameController = TextEditingController();
    _descriptionController = TextEditingController();
    _aliasController = TextEditingController();
    _preferredstreetNameController = TextEditingController();
    _leavingDate = DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _rentController.dispose();
    _townController.dispose();
    _streetNameController.dispose();
    _descriptionController.dispose();
    _aliasController.dispose();
    _preferredstreetNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              // Render different form based on selectedChoice
              if (widget.selectedChoice == 'leaving')
                _buildLeavingForm()
              else if (widget.selectedChoice == 'host')
                _buildHostForm()
              else if (widget.selectedChoice == 'looking')
                _buildLookingForm(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build "I'm leaving" form (listing for lease transfer)
  Widget _buildLeavingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Field
        _buildTextField(
          controller: _titleController,
          label: AppStrings.get('form_title_label', language: _currentLanguage),
          hint: AppStrings.get('form_title_hint', language: _currentLanguage),
        ),
        const SizedBox(height: 16),

        // Rent Field
        _buildCurrencyField(
          controller: _rentController,
          label: AppStrings.get('form_rent_label', language: _currentLanguage),
          hint: AppStrings.get('form_rent_hint', language: _currentLanguage),
        ),
        const SizedBox(height: 16),

        // Town Field (Autocomplete)
        _buildTownAutocompleteField(),
        const SizedBox(height: 16),

        // streetName Field
        _buildTextField(
          controller: _streetNameController,
          label: AppStrings.get(
            'form_streetName_label',
            language: _currentLanguage,
          ),
          hint: AppStrings.get(
            'form_streetName_hint',
            language: _currentLanguage,
          ),
        ),
        const SizedBox(height: 16),

        // Leaving Date Picker
        _buildDatePickerField(
          label: AppStrings.get(
            'form_leaving_date_label',
            language: _currentLanguage,
          ),
          selectedDate: _leavingDate,
          onDateSelected: (date) => setState(() => _leavingDate = date),
        ),
        const SizedBox(height: 16),

        // Water Available Toggle
        _buildToggleField(
          label: AppStrings.get('form_water_label', language: _currentLanguage),
          value: _waterAvailable,
          onChanged: (value) => setState(() => _waterAvailable = value),
        ),
        const SizedBox(height: 16),

        // Electricity Type Selector
        _buildRadioGroup<ElectricityType>(
          label: AppStrings.get(
            'form_electricity_label',
            language: _currentLanguage,
          ),
          value: _electricityType,
          options: {
            ElectricityType.prepaidMeter: AppStrings.get(
              'form_electricity_prepaid',
              language: _currentLanguage,
            ),
            ElectricityType.sharedMeter: AppStrings.get(
              'form_electricity_shared',
              language: _currentLanguage,
            ),
          },
          onChanged: (value) => setState(() => _electricityType = value),
        ),
        const SizedBox(height: 16),

        // Kitchen Type Selector
        _buildRadioGroup<KitchenType>(
          label: AppStrings.get(
            'form_kitchen_label',
            language: _currentLanguage,
          ),
          value: _kitchenType,
          options: {
            KitchenType.internalKitchen: AppStrings.get(
              'form_kitchen_internal',
              language: _currentLanguage,
            ),
            KitchenType.sharedKitchen: AppStrings.get(
              'form_kitchen_external',
              language: _currentLanguage,
            ),
          },
          onChanged: (value) => setState(() => _kitchenType = value),
        ),
        const SizedBox(height: 16),

        // Description Field
        _buildTextField(
          controller: _descriptionController,
          label: AppStrings.get(
            'form_description_label',
            language: _currentLanguage,
          ),
          hint: AppStrings.get(
            'form_description_hint',
            language: _currentLanguage,
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 24),

        // Photo Upload Section (optional for leaving)
        _buildPhotoUploadSection(),
        const SizedBox(height: 24),

        // Submit Button
        _buildSubmitButtons(),
      ],
    );
  }

  /// Build "Stay with me" form (host listing with compatibility)
  Widget _buildHostForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Field
        _buildTextField(
          controller: _titleController,
          label: AppStrings.get('form_title_label', language: _currentLanguage),
          hint: AppStrings.get('form_title_hint', language: _currentLanguage),
        ),
        const SizedBox(height: 16),

        // Rent Field
        _buildCurrencyField(
          controller: _rentController,
          label: AppStrings.get('form_rent_label', language: _currentLanguage),
          hint: AppStrings.get('form_rent_hint', language: _currentLanguage),
        ),
        const SizedBox(height: 16),

        // Town Field (Autocomplete)
        _buildTownAutocompleteField(),
        const SizedBox(height: 16),

        // streetName Field
        _buildTextField(
          controller: _streetNameController,
          label: AppStrings.get(
            'form_streetName_label',
            language: _currentLanguage,
          ),
          hint: AppStrings.get(
            'form_streetName_hint',
            language: _currentLanguage,
          ),
        ),
        const SizedBox(height: 24),

        // COMPATIBILITY FIELDS
        Text(
          'Roommate Compatibility',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 16),

        // Gender Preference
        _buildRadioGroup<String>(
          label: AppStrings.get(
            'host_form_gender_pref_label',
            language: _currentLanguage,
          ),
          value: _genderPreference,
          options: {
            'Males Only': AppStrings.get(
              'host_form_gender_males_only',
              language: _currentLanguage,
            ),
            'Females Only': AppStrings.get(
              'host_form_gender_females_only',
              language: _currentLanguage,
            ),
            'Open to All': AppStrings.get(
              'host_form_gender_open',
              language: _currentLanguage,
            ),
          },
          onChanged: (value) => setState(() => _genderPreference = value),
        ),
        const SizedBox(height: 16),

        // Target Age Range (Multi-select)
        _buildMultiSelectCheckboxes(
          label: AppStrings.get(
            'host_form_target_age_label',
            language: _currentLanguage,
          ),
          options: {
            '<20': AppStrings.get(
              'looking_form_age_under20',
              language: _currentLanguage,
            ),
            '20s': AppStrings.get(
              'looking_form_age_twenties',
              language: _currentLanguage,
            ),
            '30s': AppStrings.get(
              'looking_form_age_thirties',
              language: _currentLanguage,
            ),
            '40s': AppStrings.get(
              'looking_form_age_forties',
              language: _currentLanguage,
            ),
            '50+': AppStrings.get(
              'looking_form_age_over50',
              language: _currentLanguage,
            ),
          },
          selectedValues: _targetAgeRanges,
          onChanged: (values) => setState(() => _targetAgeRanges = values),
        ),
        const SizedBox(height: 16),

        // Lifestyle Match Tags
        _buildMultiSelectCheckboxes(
          label: AppStrings.get(
            'host_form_lifestyle_label',
            language: _currentLanguage,
          ),
          options: {
            'No Smoking': AppStrings.get(
              'host_form_lifestyle_no_smoking',
              language: _currentLanguage,
            ),
            'No Pets': AppStrings.get(
              'host_form_lifestyle_no_pets',
              language: _currentLanguage,
            ),
            'Quiet Space': AppStrings.get(
              'host_form_lifestyle_quiet',
              language: _currentLanguage,
            ),
          },
          selectedValues: _lifestyleTags,
          onChanged: (values) => setState(() => _lifestyleTags = values),
        ),
        const SizedBox(height: 16),

        // Expected Duration
        _buildRadioGroup<String>(
          label: AppStrings.get(
            'host_form_duration_label',
            language: _currentLanguage,
          ),
          value: _expectedDuration,
          options: {
            'Short term: 1-3 months': AppStrings.get(
              'host_form_duration_short',
              language: _currentLanguage,
            ),
            'Medium term: 6 months': AppStrings.get(
              'host_form_duration_medium',
              language: _currentLanguage,
            ),
            'Long term: 1 year+': AppStrings.get(
              'host_form_duration_long',
              language: _currentLanguage,
            ),
            'Flexible/Negotiable': AppStrings.get(
              'host_form_duration_flexible',
              language: _currentLanguage,
            ),
          },
          onChanged: (value) => setState(() => _expectedDuration = value),
        ),
        const SizedBox(height: 24),

        // Description Field
        _buildTextField(
          controller: _descriptionController,
          label: AppStrings.get(
            'form_description_label',
            language: _currentLanguage,
          ),
          hint: AppStrings.get(
            'form_description_hint',
            language: _currentLanguage,
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 24),

        // Photo Upload Section (optional)
        _buildPhotoUploadSection(),
        const SizedBox(height: 24),

        // Submit Button
        _buildSubmitButtons(),
      ],
    );
  }

  /// Build "Looking for room" form (minimal searcher profile)
  Widget _buildLookingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Alias Field
        _buildTextField(
          controller: _aliasController,
          label: AppStrings.get(
            'looking_form_alias_label',
            language: _currentLanguage,
          ),
          hint: AppStrings.get(
            'looking_form_alias_hint',
            language: _currentLanguage,
          ),
        ),
        const SizedBox(height: 16),

        // Age Range
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get(
                'looking_form_age_label',
                language: _currentLanguage,
              ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['<20', '20s', '30s', '40s', '50+'].map((age) {
                return FilterChip(
                  label: Text(
                    AppStrings.get(
                      'looking_form_age_${age.replaceAll("+", "plus")}',
                      language: _currentLanguage,
                    ),
                  ),
                  selected: _ageRange == age,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _ageRange = age);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Preferred Town
        _buildTownAutocompleteField(),
        const SizedBox(height: 16),

        // Preferred streetName (Optional)
        _buildTextField(
          controller: _preferredstreetNameController,
          label: AppStrings.get(
            'looking_form_preferred_streetName_label',
            language: _currentLanguage,
          ),
          hint: AppStrings.get(
            'looking_form_preferred_streetName_hint',
            language: _currentLanguage,
          ),
        ),
        const SizedBox(height: 24),

        // Submit Button
        _buildSubmitButtons(),
      ],
    );
  }

  /// Build standard text input field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
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
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  /// Build currency input field (CFA suffix)
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppStrings.get('form_rent_suffix', language: _currentLanguage),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build town autocomplete field
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
            final query = value.text.trim();
            if (query.isEmpty) return const Iterable<String>.empty();

            final resolvedAlias = AppStrings.resolveTownAlias(query);
            if (resolvedAlias != null) {
              return [resolvedAlias];
            }

            final normalizedQuery = AppStrings.normalizeTownText(query);
            final matches = AppStrings.cameroonTowns.where((town) {
              final normalizedTown = AppStrings.normalizeTownText(town);
              return normalizedTown.contains(normalizedQuery) ||
                  normalizedQuery.contains(normalizedTown);
            });
            return matches;
          },
          onSelected: (selection) {
            _townController.text = selection;
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            controller.text = _townController.text;
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length),
            );
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: AppStrings.get(
                  'form_town_hint',
                  language: _currentLanguage,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                _townController.text = value;
              },
              onSubmitted: (_) => onFieldSubmitted(),
            );
          },
        ),
      ],
    );
  }

  /// Build date picker field
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
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: selectedDate != null ? Colors.black : Colors.grey,
                  ),
                ),
                const Icon(Icons.calendar_today_rounded),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build toggle switch field
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
          activeThumbColor: Colors.blue.shade700,
        ),
      ],
    );
  }

  /// Build radio group selector
  Widget _buildRadioGroup<T>({
    required String label,
    required T value,
    required Map<T, String> options,
    required Function(T) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        RadioGroup<T>(
          groupValue: value,
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
          child: Column(
            children: options.entries.map((entry) {
              return RadioListTile<T>(
                value: entry.key,
                title: Text(entry.value),
                contentPadding: EdgeInsets.zero,
                dense: true,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Build multi-select checkboxes
  Widget _buildMultiSelectCheckboxes({
    required String label,
    required Map<String, String> options,
    required Set<String> selectedValues,
    required Function(Set<String>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        ...options.entries.map((entry) {
          return CheckboxListTile(
            value: selectedValues.contains(entry.key),
            onChanged: (checked) {
              final newSet = Set<String>.from(selectedValues);
              if (checked == true) {
                newSet.add(entry.key);
              } else {
                newSet.remove(entry.key);
              }
              onChanged(newSet);
            },
            title: Text(entry.value),
            contentPadding: EdgeInsets.zero,
            dense: true,
          );
        }),
      ],
    );
  }

  /// Build submit and cancel buttons
  Widget _buildSubmitButtons() {
    return Column(
      children: [
        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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

        // Cancel Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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

  Widget _buildPhotoUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get('form_photos_label', language: _currentLanguage),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),

        // Photo Grid (3 boxes max)
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            ...List.generate(_selectedImagePaths.length, (index) {
              return _buildPhotoBox(index);
            }),

            // Add photo button (if < 3 photos)
            if (_selectedImagePaths.length < 3)
              InkWell(
                onTap: _launchImageSourceSheet,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_rounded,
                      size: 32,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Photo count indicator
        Text(
          AppStrings.getWithParams('form_photos_count', {
            'count': _selectedImagePaths.length.toString(),
          }, language: _currentLanguage),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),

        const SizedBox(height: 12),

        // Image Compression Helper Note (EN & FR)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Text(
            AppStrings.get('form_photos_helper', language: _currentLanguage),
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade900,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  /// Build individual photo box
  Widget _buildPhotoBox(int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            image: _selectedImagePaths.length > index
                ? DecorationImage(
                    image: FileImage(File(_selectedImagePaths[index])),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedImagePaths.removeAt(index);
              });
            },
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

  /// Launch image source selection sheet
  Future<void> _launchImageSourceSheet() async {
    if (_selectedImagePaths.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.get('form_photos_error', language: _currentLanguage),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Choose from photo library'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Use camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      if (source == ImageSource.gallery) {
        final List<XFile> pickedFiles = await picker.pickMultiImage(
          maxWidth: 1600,
          imageQuality: 80,
        );

        if (pickedFiles.isEmpty) return;

        final selected = <String>[];
        for (final file in pickedFiles) {
          if (selected.length >= 3) break;
          if (_selectedImagePaths.length + selected.length >= 3) break;
          selected.add(file.path);
        }

        if (selected.isEmpty) return;

        if (!mounted) return;
        setState(() {
          _selectedImagePaths.addAll(selected);
          if (_selectedImagePaths.length > 3) {
            _selectedImagePaths = _selectedImagePaths.sublist(0, 3);
          }
        });
      } else {
        final XFile? picked = await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1600,
          imageQuality: 80,
        );

        if (picked == null) return;

        if (_selectedImagePaths.length >= 3) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppStrings.get('form_photos_error', language: _currentLanguage),
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        if (!mounted) return;
        setState(() {
          _selectedImagePaths.add(picked.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open image picker: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Submit form - navigate to confirmation screen
  void _submitForm() {
    // Validate based on form type
    if (widget.selectedChoice == 'leaving') {
      if (_titleController.text.isEmpty ||
          _rentController.text.isEmpty ||
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

      final listing = KDListing(
        id: DateTime.now().millisecondsSinceEpoch.toString(),

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
        userId: 'current_user',
      );

      debugPrint('Submitted leaving listing: ${listing.town}');
    } else if (widget.selectedChoice == 'host') {
      if (_titleController.text.isEmpty ||
          _rentController.text.isEmpty ||
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

      debugPrint(
        'Submitted host listing: ' +
            '${_titleController.text}, Gender: $_genderPreference, ' +
            'Ages: $_targetAgeRanges, Lifestyle: $_lifestyleTags, ' +
            'Duration: $_expectedDuration',
      );
    } else if (widget.selectedChoice == 'looking') {
      if (_aliasController.text.isEmpty || _townController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.get('error', language: _currentLanguage)),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      debugPrint(
        'Submitted looking profile: ${_aliasController.text}, ' +
            'Age: $_ageRange, Town: ${_townController.text}, ' +
            'streetName: ${_preferredstreetNameController.text}',
      );
    }

    // Navigate to confirmation screen on success
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => KDConfirmationScreen(currentLanguage: _currentLanguage),
      ),
      (route) => route.isFirst,
    );
  }
}
