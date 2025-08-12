import 'package:flutter/material.dart';
import 'package:manifest_desktop/layouts/master_screen.dart';
import 'package:manifest_desktop/model/festival.dart';
import 'package:manifest_desktop/model/subcategory.dart';
import 'package:manifest_desktop/model/search_result.dart';
import 'package:manifest_desktop/providers/festival_provider.dart';
import 'package:manifest_desktop/providers/subcategory_provider.dart';
import 'package:manifest_desktop/screens/festival_details_screen.dart';
import 'package:manifest_desktop/utils/base_pagination.dart';
import 'package:manifest_desktop/utils/base_table.dart';
import 'package:manifest_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';

class FestivalListScreen extends StatefulWidget {
  const FestivalListScreen({super.key});

  @override
  State<FestivalListScreen> createState() => _FestivalListScreenState();
}

class _FestivalListScreenState extends State<FestivalListScreen> {
  late FestivalProvider festivalProvider;
  late SubcategoryProvider subcategoryProvider;
  List<Subcategory> subcategories = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  int? selectedSubcategoryId;

  SearchResult<Festival>? festivals;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;

    final filter = {
      'title': titleController.text,
      'cityName': cityController.text,
      'subcategoryId': selectedSubcategoryId,
      'page': pageToFetch,
      'pageSize': pageSizeToUse,
      'includeTotalCount': true,
    };

    final result = await festivalProvider.get(filter: filter);
    setState(() {
      festivals = result;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      festivalProvider = context.read<FestivalProvider>();
      subcategoryProvider = context.read<SubcategoryProvider>();
      await _loadSubcategories();
      await _performSearch(page: 0);
    });
  }

  Future<void> _loadSubcategories() async {
    try {
      final result = await subcategoryProvider.get(
        filter: {
          'page': 0,
          'pageSize': 1000, // Get all subcategories
          'includeTotalCount': false,
        },
      );
      if (result.items != null) {
        setState(() {
          subcategories = result.items!;
        });
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Festivals',
      child: Center(
        child: Column(
          children: [
            _buildSearch(),
            Expanded(child: _buildResultView()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: customTextFieldDecoration(
                    'Title',
                    prefixIcon: Icons.festival,
                  ),
                  controller: titleController,
                  onSubmitted: (_) => _performSearch(page: 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: customTextFieldDecoration(
                    'City',
                    prefixIcon: Icons.location_city,
                  ),
                  controller: cityController,
                  onSubmitted: (_) => _performSearch(page: 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<int>(
                    value: selectedSubcategoryId,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: InputBorder.none,
                      hintText: 'Select Subcategory',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('All Subcategories'),
                      ),
                      ...subcategories.map(
                        (subcategory) => DropdownMenuItem<int>(
                          value: subcategory.id,
                          child: Text(subcategory.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedSubcategoryId = value;
                      });
                      _performSearch(page: 0);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _performSearch,
                    child: const Text('Search'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      titleController.clear();
                      cityController.clear();
                      setState(() {
                        selectedSubcategoryId = null;
                      });
                      _performSearch(page: 0);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final isEmpty =
        festivals == null ||
        festivals!.items == null ||
        festivals!.items!.isEmpty;
    final int totalCount = festivals?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTable(
            icon: Icons.festival,
            title: 'Festivals',
            width: 1400,
            height: 423,
            columnWidths: [
              250, // Title
              150, // Date Range

              150, // City
              130, // Subcategory

              80, // Status
              100, // Actions
            ],
            columns: const [
              DataColumn(
                label: Text(
                  'Title',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Date Range',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),

              DataColumn(
                label: Text(
                  'City',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Subcategory',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),

              DataColumn(
                label: Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Actions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
            rows: isEmpty
                ? []
                : festivals!.items!
                      .map(
                        (e) => DataRow(
                          cells: [
                            DataCell(
                              Text(
                                e.title,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              Text(
                                e.dateRange,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),

                            DataCell(
                              Text(
                                e.cityName,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              Text(
                                e.subcategoryName,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),

                            DataCell(
                              Icon(
                                e.isActive ? Icons.check_circle : Icons.cancel,
                                color: e.isActive ? Colors.green : Colors.red,
                                size: 20,
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FestivalDetailsScreen(
                                                festival: e,
                                              ),
                                          settings: const RouteSettings(
                                            name: 'FestivalDetailsScreen',
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.info_outline,
                                      color: Colors.blue,
                                    ),
                                    tooltip: 'View Details',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
            emptyIcon: Icons.festival,
            emptyText: 'No festivals found.',
            emptySubtext: 'Try adjusting your search criteria.',
          ),
          const SizedBox(height: 30),
          BasePagination(
            currentPage: _currentPage,
            totalPages: totalPages,
            onPrevious: isFirstPage
                ? null
                : () => _performSearch(page: _currentPage - 1),
            onNext: isLastPage
                ? null
                : () => _performSearch(page: _currentPage + 1),
            showPageSizeSelector: true,
            pageSize: _pageSize,
            pageSizeOptions: _pageSizeOptions,
            onPageSizeChanged: (newSize) {
              if (newSize != null && newSize != _pageSize) {
                _performSearch(page: 0, pageSize: newSize);
              }
            },
          ),
        ],
      ),
    );
  }
}
