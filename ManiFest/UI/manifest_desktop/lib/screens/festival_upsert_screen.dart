import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:manifest_desktop/layouts/master_screen.dart';
import 'package:manifest_desktop/model/festival.dart';

import 'package:manifest_desktop/model/asset.dart';
import 'package:manifest_desktop/model/city.dart';
import 'package:manifest_desktop/model/subcategory.dart';
import 'package:manifest_desktop/model/organizer.dart';
import 'package:manifest_desktop/providers/festival_provider.dart';
import 'package:manifest_desktop/providers/asset_provider.dart';
import 'package:manifest_desktop/providers/city_provider.dart';
import 'package:manifest_desktop/providers/subcategory_provider.dart';
import 'package:manifest_desktop/providers/organizer_provider.dart';
import 'package:manifest_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';

class FestivalUpsertScreen extends StatefulWidget {
  final Festival? festival; // null for create, Festival object for edit

  const FestivalUpsertScreen({super.key, this.festival});

  @override
  State<FestivalUpsertScreen> createState() => _FestivalUpsertScreenState();
}

class _FestivalUpsertScreenState extends State<FestivalUpsertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  int? _selectedCityId;
  int? _selectedSubcategoryId;
  int? _selectedOrganizerId;
  bool _isActive = true;

  List<Asset> _existingAssets = [];
  List<File> _newImages = [];
  List<String> _assetsToDelete = [];

  late FestivalProvider _festivalProvider;
  late AssetProvider _assetProvider;
  late CityProvider _cityProvider;
  late SubcategoryProvider _subcategoryProvider;
  late OrganizerProvider _organizerProvider;

  List<City> _cities = [];
  List<Subcategory> _subcategories = [];
  List<Organizer> _organizers = [];

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.festival != null;
    _initializeData();
  }

  Future<void> _initializeData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _festivalProvider = context.read<FestivalProvider>();
      _assetProvider = context.read<AssetProvider>();
      _cityProvider = context.read<CityProvider>();
      _subcategoryProvider = context.read<SubcategoryProvider>();
      _organizerProvider = context.read<OrganizerProvider>();

      await Future.wait([
        _loadCities(),
        _loadSubcategories(),
        _loadOrganizers(),
      ]);

      if (_isEditing) {
        _populateForm();
        await _loadExistingAssets();
      }
    });
  }

  Future<void> _loadCities() async {
    try {
      final result = await _cityProvider.get(
        filter: {'page': 0, 'pageSize': 1000, 'includeTotalCount': false},
      );
      if (result.items != null) {
        setState(() {
          _cities = result.items!;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadSubcategories() async {
    try {
      final result = await _subcategoryProvider.get(
        filter: {'page': 0, 'pageSize': 1000, 'includeTotalCount': false},
      );
      if (result.items != null) {
        setState(() {
          _subcategories = result.items!;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadOrganizers() async {
    try {
      final result = await _organizerProvider.get(
        filter: {'page': 0, 'pageSize': 1000, 'includeTotalCount': false},
      );
      if (result.items != null) {
        setState(() {
          _organizers = result.items!;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadExistingAssets() async {
    if (widget.festival != null) {
      try {
        final result = await _assetProvider.get(
          filter: {'festivalId': widget.festival!.id},
        );
        if (result.items != null) {
          setState(() {
            _existingAssets = result.items!;
          });
        }
      } catch (e) {
        // Handle error
      }
    }
  }

  void _populateForm() {
    final festival = widget.festival!;
    _titleController.text = festival.title;
    _basePriceController.text = festival.basePrice.toString();
    _locationController.text = festival.location ?? '';
    _startDate = festival.startDate;
    _endDate = festival.endDate;
    _selectedCityId = festival.cityId;
    _selectedSubcategoryId = festival.subcategoryId;
    _selectedOrganizerId = festival.organizerId;
    _isActive = festival.isActive;
  }

  Future<void> _pickImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _newImages.addAll(
            result.paths
                .map((path) => File(path!))
                .where((file) => file.existsSync()),
          );
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  void _removeExistingAsset(String assetId) {
    setState(() {
      _assetsToDelete.add(assetId);
      _existingAssets.removeWhere((asset) => asset.id.toString() == assetId);
    });
  }

  Future<void> _saveFestival() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = {
        'title': _titleController.text.trim(),
        'startDate': _startDate!.toIso8601String(),
        'endDate': _endDate!.toIso8601String(),
        'basePrice': double.parse(_basePriceController.text),
        'location': _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        'cityId': _selectedCityId!,
        'subcategoryId': _selectedSubcategoryId!,
        'organizerId': _selectedOrganizerId!,
        'isActive': _isActive,
      };

      Festival savedFestival;
      if (_isEditing) {
        savedFestival = await _festivalProvider.update(
          widget.festival!.id,
          request,
        );
      } else {
        savedFestival = await _festivalProvider.insert(request);
      }

      // Handle assets
      await _handleAssets(savedFestival.id);

      // Delete marked assets
      for (String assetId in _assetsToDelete) {
        await _assetProvider.delete(int.parse(assetId));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Festival updated successfully!'
                  : 'Festival created successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAssets(int festivalId) async {
    // Upload new images
    for (File imageFile in _newImages) {
      try {
        final bytes = await imageFile.readAsBytes();
        final base64String = base64Encode(bytes);
        final fileName = imageFile.path.split('/').last;
        final contentType = 'image/${fileName.split('.').last}';

        await _assetProvider.insert({
          'fileName': fileName,
          'contentType': contentType,
          'base64Content': base64String,
          'festivalId': festivalId,
        });
      } catch (e) {
        // Handle individual asset upload error
        print('Error uploading asset: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: _isEditing ? 'Edit Festival' : 'New Festival',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoCard(),
              const SizedBox(height: 20),
              _buildLocationCard(),
              const SizedBox(height: 20),
              _buildAssetsCard(),
              const SizedBox(height: 30),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _titleController,
                    decoration: customTextFieldDecoration(
                      'Festival Title',
                      prefixIcon: Icons.festival,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a festival title';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextFormField(
                    controller: _basePriceController,
                    decoration: customTextFieldDecoration(
                      'Base Price',
                      prefixIcon: Icons.attach_money,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a base price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    'Start Date',
                    _startDate,
                    (date) => setState(() => _startDate = date),
                    Icons.calendar_today,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildDateField(
                    'End Date',
                    _endDate,
                    (date) => setState(() => _endDate = date),
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    'City',
                    _selectedCityId,
                    _cities
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    (value) => setState(() => _selectedCityId = value),
                    Icons.location_city,
                    'Select City',
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildDropdown(
                    'Subcategory',
                    _selectedSubcategoryId,
                    _subcategories
                        .map(
                          (s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          ),
                        )
                        .toList(),
                    (value) => setState(() => _selectedSubcategoryId = value),
                    Icons.category,
                    'Select Subcategory',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    'Organizer',
                    _selectedOrganizerId,
                    _organizers
                        .map(
                          (o) => DropdownMenuItem(
                            value: o.id,
                            child: Text(o.name),
                          ),
                        )
                        .toList(),
                    (value) => setState(() => _selectedOrganizerId = value),
                    Icons.person,
                    'Select Organizer',
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isActive,
                        onChanged: (value) =>
                            setState(() => _isActive = value ?? true),
                      ),
                      const Text('Active'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _locationController,
              decoration: customTextFieldDecoration(
                'Coordinates (e.g., 43.8563,18.4131)',
                prefixIcon: Icons.location_on,
              ),
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  final coords = value.trim().split(',');
                  if (coords.length != 2) {
                    return 'Please enter coordinates in format: latitude,longitude';
                  }
                  if (double.tryParse(coords[0]) == null ||
                      double.tryParse(coords[1]) == null) {
                    return 'Please enter valid coordinates';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Festival Assets',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Images'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Existing assets
            if (_existingAssets.isNotEmpty) ...[
              Text(
                'Existing Assets',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _existingAssets.map((asset) {
                  if (_assetsToDelete.contains(asset.id.toString()))
                    return const SizedBox.shrink();

                  return Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            base64Decode(asset.base64Content),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () =>
                              _removeExistingAsset(asset.id.toString()),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // New images
            if (_newImages.isNotEmpty) ...[
              Text(
                'New Images',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _newImages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final image = entry.value;

                  return Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(image, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeNewImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],

            if (_existingAssets.isEmpty && _newImages.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No assets added yet',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Click "Add Images" to upload festival photos',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.black87,
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveFestival,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(_isEditing ? 'Update Festival' : 'Create Festival'),
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? selectedDate,
    Function(DateTime?) onDateSelected,
    IconData icon,
  ) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedDate != null
                    ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                    : label,
                style: TextStyle(
                  color: selectedDate != null
                      ? Colors.black
                      : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    int? selectedValue,
    List<DropdownMenuItem<int>> items,
    Function(int?) onChanged,
    IconData icon,
    String hint,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<int>(
        value: selectedValue,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: InputBorder.none,
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
        items: [
          DropdownMenuItem<int>(value: null, child: Text('Select $label')),
          ...items,
        ],
        onChanged: onChanged,
        validator: (value) {
          if (value == null) {
            return 'Please select a $label';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _basePriceController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
