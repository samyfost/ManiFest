import 'package:flutter/material.dart';
import 'package:manifest_desktop/layouts/master_screen.dart';
import 'package:manifest_desktop/model/ticket.dart';
import 'package:manifest_desktop/model/search_result.dart';
import 'package:manifest_desktop/providers/ticket_provider.dart';
import 'package:manifest_desktop/screens/ticket_details_screen.dart';
import 'package:manifest_desktop/utils/base_pagination.dart';
import 'package:manifest_desktop/utils/base_table.dart';
import 'package:manifest_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  late TicketProvider ticketProvider;

  final TextEditingController userFullNameController = TextEditingController();
  final TextEditingController festivalTitleController = TextEditingController();

  SearchResult<Ticket>? tickets;
  int _currentPage = 0;
  int _pageSize = 10;
  final List<int> _pageSizeOptions = [5, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;

    final filter = {
      'userFullName': userFullNameController.text,
      'festivalTitle': festivalTitleController.text,
      'page': pageToFetch,
      'pageSize': pageSizeToUse,
      'includeTotalCount': true,
    };

    final result = await ticketProvider.get(filter: filter);
    setState(() {
      tickets = result;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ticketProvider = context.read<TicketProvider>();
      await _performSearch(page: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Tickets',
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
                    'User Full Name',
                    prefixIcon: Icons.person,
                  ),
                  controller: userFullNameController,
                  onSubmitted: (_) => _performSearch(page: 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: customTextFieldDecoration(
                    'Festival Title',
                    prefixIcon: Icons.festival,
                  ),
                  controller: festivalTitleController,
                  onSubmitted: (_) => _performSearch(page: 0),
                ),
              ),
              const SizedBox(width: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _performSearch(page: 0),
                    child: const Text('Search'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      userFullNameController.clear();
                      festivalTitleController.clear();
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
        tickets == null || tickets!.items == null || tickets!.items!.isEmpty;
    final int totalCount = tickets?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTable(
            icon: Icons.confirmation_number,
            title: 'Tickets',
            width: 1200,
            height: 423,
            columnWidths: [
              200, // Festival
              150, // User Full Name
              100, // Ticket Type
              100, // Price
              150, // Generated Code
              100, // Status
              100, // Actions
            ],
            columns: const [
              DataColumn(
                label: Text(
                  'Festival',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'User Full Name',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Ticket Type',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Price',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Generated Code',
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
                : tickets!.items!
                      .map(
                        (e) => DataRow(
                          cells: [
                            DataCell(
                              Text(
                                e.festivalTitle,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              Text(
                                e.userFullName,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              Text(
                                e.ticketTypeName,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              Text(
                                '\$${e.finalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              Text(
                                e.generatedCode,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: e.isRedeemed
                                      ? Colors.red
                                      : Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  e.isRedeemed ? 'Redeemed' : 'Active',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TicketDetailsScreen(ticket: e),
                                      settings: const RouteSettings(
                                        name: 'TicketDetailsScreen',
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
                            ),
                          ],
                        ),
                      )
                      .toList(),
            emptyIcon: Icons.confirmation_number,
            emptyText: 'No tickets found.',
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
