import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:manifest_desktop/layouts/master_screen.dart';
import 'package:manifest_desktop/model/user.dart';
import 'package:manifest_desktop/model/city.dart';
import 'package:manifest_desktop/providers/user_provider.dart';
import 'package:manifest_desktop/providers/city_provider.dart';
import 'package:manifest_desktop/utils/base_textfield.dart';
import 'package:manifest_desktop/screens/users_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class UsersEditScreen extends StatefulWidget {
  final User user;

  const UsersEditScreen({super.key, required this.user});

  @override
  State<UsersEditScreen> createState() => _UsersEditScreenState();
}

class _UsersEditScreenState extends State<UsersEditScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late UserProvider userProvider;
  late CityProvider cityProvider;
  bool isLoading = true;
  bool _isLoadingCities = true;
  List<City> _cities = [];
  City? _selectedCity;
  File? _image;

  final double leftColumnWidth = 300;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    cityProvider = Provider.of<CityProvider>(context, listen: false);
    _initialValue = {
      "firstName": widget.user.firstName,
      "lastName": widget.user.lastName,
      "email": widget.user.email,
      "username": widget.user.username,
      "phoneNumber": widget.user.phoneNumber ?? '',
      "isActive": widget.user.isActive,
      "picture": widget.user.picture,
    };
    initFormData();
    _loadCities();
  }

  initFormData() async {
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadCities() async {
    try {
      setState(() {
        _isLoadingCities = true;
      });

      final result = await cityProvider.get();
      if (result.items != null && result.items!.isNotEmpty) {
        setState(() {
          _cities = result.items!;
          _isLoadingCities = false;
        });
        _setDefaultCitySelection();
      } else {
        setState(() {
          _cities = [];
          _isLoadingCities = false;
        });
      }
    } catch (e) {
      setState(() {
        _cities = [];
        _isLoadingCities = false;
      });
    }
  }

  void _setDefaultCitySelection() {
    if (_cities.isNotEmpty) {
      try {
        _selectedCity = _cities.firstWhere(
          (city) => city.id == widget.user.cityId,
          orElse: () => _cities.first,
        );
      } catch (e) {
        _selectedCity = _cities.first;
      }
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      _image = File(result.files.single.path!);
      _initialValue['picture'] = base64Encode(_image!.readAsBytesSync());
      setState(() {});
    }
  }

  Widget _buildCityDropdown() {
    if (_isLoadingCities) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text("Loading cities...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_cities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          "No cities available",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return DropdownButtonFormField<City>(
      value: _selectedCity,
      decoration: customTextFieldDecoration(
        "City",
        prefixIcon: Icons.location_city,
      ),
      items: _cities.map((city) {
        return DropdownMenuItem<City>(value: city, child: Text(city.name));
      }).toList(),
      onChanged: (City? value) {
        setState(() {
          _selectedCity = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return "Please select a city";
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Edit User",
      showBackButton: true,
      child: _buildForm(),
    );
  }

  Widget _buildSaveButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.cancel),
            label: const Text("Cancel"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              formKey.currentState?.saveAndValidate();
              if (formKey.currentState?.validate() ?? false) {
                if (_selectedCity == null) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Validation Error'),
                      content: const Text('Please select a city'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                var request = Map.from(formKey.currentState?.value ?? {});
                request['cityId'] = _selectedCity!.id;
                request['genderId'] =
                    widget.user.genderId; // Keep existing gender
                request['picture'] = _initialValue['picture'];

                try {
                  await userProvider.update(widget.user.id, request);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User updated successfully'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 1),
                    ),
                  );
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const UsersListScreen(),
                      settings: const RouteSettings(name: 'UsersListScreen'),
                    ),
                  );
                } catch (e) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Error'),
                      content: Text(
                        e.toString().replaceFirst('Exception: ', ''),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.save),
            label: const Text("Save"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: FormBuilder(
                key: formKey,
                initialValue: _initialValue,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with back button
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back),
                          tooltip: 'Go back',
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.person,
                          size: 32,
                          color: Color(0xFF6A1B9A),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          "Edit User",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A1B9A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Measure left column height dynamically by using IntrinsicHeight on the whole row
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left column: picture + buttons
                          SizedBox(
                            width: leftColumnWidth,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Profile Picture",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child:
                                      _initialValue['picture'] != null &&
                                          (_initialValue['picture'] as String)
                                              .isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Image.memory(
                                            base64Decode(
                                              _initialValue['picture'],
                                            ),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return _buildImagePlaceholder();
                                                },
                                          ),
                                        )
                                      : _buildImagePlaceholder(),
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _pickImage,
                                        icon: const Icon(Icons.photo_library),
                                        label: const Text("Select Image"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF6A1B9A,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _image = null;
                                            _initialValue['picture'] = null;
                                          });
                                        },
                                        icon: const Icon(Icons.clear),
                                        label: const Text("Clear Image"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            162,
                                            159,
                                            159,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 24),

                          // Middle column aligned to bottom
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FormBuilderTextField(
                                    name: "firstName",
                                    decoration: customTextFieldDecoration(
                                      "First Name",
                                      prefixIcon: Icons.person_outline,
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.match(
                                        RegExp(r'^[\p{L} ]+$', unicode: true),
                                        errorText:
                                            'Only letters (including international), and spaces allowed',
                                      ),
                                    ]),
                                  ),
                                  const SizedBox(height: 16),
                                  FormBuilderTextField(
                                    name: "lastName",
                                    decoration: customTextFieldDecoration(
                                      "Last Name",
                                      prefixIcon: Icons.person_outline,
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.match(
                                        RegExp(r'^[\p{L} ]+$', unicode: true),
                                        errorText:
                                            'Only letters (including international), and spaces allowed',
                                      ),
                                    ]),
                                  ),
                                  const SizedBox(height: 16),
                                  FormBuilderTextField(
                                    name: "username",
                                    decoration: customTextFieldDecoration(
                                      "Username",
                                      prefixIcon: Icons.alternate_email,
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.minLength(3),
                                      FormBuilderValidators.maxLength(50),
                                    ]),
                                  ),
                                  const SizedBox(height: 16),
                                  FormBuilderTextField(
                                    name: "email",
                                    decoration: customTextFieldDecoration(
                                      "Email",
                                      prefixIcon: Icons.email,
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.email(),
                                    ]),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 24),

                          // Right column aligned to bottom
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FormBuilderTextField(
                                    name: "phoneNumber",
                                    decoration: customTextFieldDecoration(
                                      "Phone Number (Optional)",
                                      prefixIcon: Icons.phone,
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.match(
                                        RegExp(r'^[\d\s\-\+\(\)]+$'),
                                        errorText:
                                            'Please enter a valid phone number',
                                      ),
                                    ]),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildCityDropdown(),
                                  const SizedBox(height: 16),
                                  FormBuilderTextField(
                                    name: "genderName",
                                    initialValue: widget.user.genderName,
                                    enabled: false,
                                    decoration: customTextFieldDecoration(
                                      "Gender",
                                      prefixIcon: Icons.person,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  FormBuilderSwitch(
                                    name: 'isActive',
                                    title: const Text('Active Account'),
                                    initialValue:
                                        _initialValue['isActive'] as bool? ??
                                        true,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 8),
        const Text(
          "No profile picture",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        const Text(
          textAlign: TextAlign.center,
          "Click 'Select Image' to add a profile picture",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
