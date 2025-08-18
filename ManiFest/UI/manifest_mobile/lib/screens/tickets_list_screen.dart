import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:manifest_mobile/model/ticket.dart';
import 'package:manifest_mobile/model/search_result.dart';
import 'package:manifest_mobile/providers/ticket_provider.dart';
import 'package:manifest_mobile/providers/user_provider.dart';
import 'package:manifest_mobile/screens/ticket_info.dart';
import 'package:provider/provider.dart';

class TicketsListScreen extends StatefulWidget {
  const TicketsListScreen({super.key});

  @override
  State<TicketsListScreen> createState() => _TicketsListScreenState();
}

class _TicketsListScreenState extends State<TicketsListScreen> {
  late TicketProvider ticketProvider;
  TextEditingController searchController = TextEditingController();
  SearchResult<Ticket>? tickets;
  bool _isLoading = false;
  String _searchText = '';

  Future<void> _performSearch() async {
    if (UserProvider.currentUser == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Load user tickets (primary list)
      var result = await ticketProvider.get(
        filter: {
          "page": 0,
          "pageSize": 100,
          "includeTotalCount": true,
          "userId": UserProvider.currentUser!.id,
          if (_searchText.isNotEmpty) "festivalTitle": _searchText,
        },
      );

      setState(() {
        tickets = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading tickets: $e"),
          backgroundColor: const Color(0xFF6A1B9A),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ticketProvider = Provider.of<TicketProvider>(context, listen: false);
      await _performSearch();
    });
  }

  Widget _buildTicketCard(Ticket ticket) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1B9A).withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TicketInfoScreen(ticket: ticket),
            ),
          ).then((_) => _performSearch());
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          ticket.festivalLogo != null &&
                              ticket.festivalLogo!.isNotEmpty
                          ? Image.memory(
                              base64Decode(ticket.festivalLogo!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.confirmation_number,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.primary,
                                );
                              },
                            )
                          : Icon(
                              Icons.confirmation_number,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                ticket.festivalTitle,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D1B69),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: ticket.isRedeemed
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                ticket.isRedeemed ? 'Redeemed' : 'Not redeemed',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ticket.isRedeemed
                                      ? Colors.green[700]
                                      : Colors.orange[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Type: ${ticket.ticketTypeName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TicketInfoScreen(ticket: ticket),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text('Redeem Code'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF6A1B9A).withOpacity(0.1),
            const Color(0xFF6A1B9A).withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6A1B9A).withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search by festival names...",
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF6A1B9A),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchText = value);
                      _performSearch();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6A1B9A)),
                  )
                : tickets == null || tickets!.items?.isEmpty == true
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6A1B9A).withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.confirmation_number_outlined,
                            size: 64,
                            color: const Color(0xFF6A1B9A).withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "No tickets found",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D1B69),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tickets you purchase will appear here",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _performSearch,
                    color: const Color(0xFF6A1B9A),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: tickets!.items?.length ?? 0,
                      itemBuilder: (context, index) {
                        return _buildTicketCard(tickets!.items![index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
