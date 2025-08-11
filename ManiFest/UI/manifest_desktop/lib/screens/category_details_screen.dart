import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:manifest_desktop/layouts/master_screen.dart';
import 'package:manifest_desktop/model/category.dart';
import 'package:manifest_desktop/providers/category_provider.dart';
import 'package:manifest_desktop/screens/category_list_screen.dart';
import 'package:manifest_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final Category? item;
  const CategoryDetailsScreen({super.key, this.item});

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  late CategoryProvider categoryProvider;
  Map<String, dynamic> initialValue = {};

  @override
  void initState() {
    super.initState();
    categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    initialValue = {
      'name': widget.item?.name ?? '',
      'description': widget.item?.description ?? '',
      'isActive': widget.item?.isActive ?? true,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: widget.item == null ? 'Add Category' : 'Edit Category',
      showBackButton: true,
      child: _buildForm(),
    );
  }

  Widget _buildForm() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: FormBuilder(
              key: formKey,
              initialValue: initialValue,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Go back',
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.category,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        widget.item != null
                            ? 'Edit Category'
                            : 'Add New Category',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  FormBuilderTextField(
                    name: 'name',
                    decoration: customTextFieldDecoration(
                      'Category Name',
                      prefixIcon: Icons.text_fields,
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  FormBuilderTextField(
                    name: 'description',
                    decoration: customTextFieldDecoration(
                      'Description',
                      prefixIcon: Icons.notes,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  FormBuilderSwitch(
                    name: 'isActive',
                    title: const Text('Active'),
                    initialValue: initialValue['isActive'] as bool? ?? true,
                  ),
                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancel'),
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
                              final request = Map<String, dynamic>.from(
                                formKey.currentState?.value ?? {},
                              );
                              try {
                                if (widget.item == null) {
                                  await categoryProvider.insert(request);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Category created successfully',
                                      ),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                } else {
                                  await categoryProvider.update(
                                    widget.item!.id,
                                    request,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Category updated successfully',
                                      ),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CategoryListScreen(),
                                  ),
                                );
                              } catch (e) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Error'),
                                    content: Text(
                                      e.toString().replaceFirst(
                                        'Exception: ',
                                        '',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Save'),
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
