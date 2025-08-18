import 'package:flutter/material.dart';
import 'package:manifest_mobile/model/festival.dart';
import 'package:manifest_mobile/model/ticket.dart';
import 'package:manifest_mobile/model/review.dart';
import 'package:manifest_mobile/model/search_result.dart';
import 'package:manifest_mobile/providers/festival_provider.dart';
import 'package:manifest_mobile/providers/ticket_provider.dart';
import 'package:manifest_mobile/providers/review_provider.dart';
import 'package:manifest_mobile/providers/user_provider.dart';
import 'package:manifest_mobile/screens/review_details_screen.dart';
import 'package:provider/provider.dart';

class FestivalSelectionScreen extends StatefulWidget {
  const FestivalSelectionScreen({super.key});

  @override
  State<FestivalSelectionScreen> createState() =>
      _FestivalSelectionScreenState();
}

class _FestivalSelectionScreenState extends State<FestivalSelectionScreen> {
  late TicketProvider ticketProvider;
  late ReviewProvider reviewProvider;
  TextEditingController searchController = TextEditingController();
  List<Ticket> availableTickets = [];
  bool _isLoading = false;
  String _searchText = '';

  Future<void> _loadAvailableTickets() async {
    if (UserProvider.currentUser == null) {
      print("No current user found");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Step 1: Get all tickets for the current user
      var ticketFilter = {
        "page": 0,
        "pageSize": 1000, // Get all tickets
        "includeTotalCount": false,
        "userId": UserProvider.currentUser!.id,
      };

      var ticketsResult = await ticketProvider.get(filter: ticketFilter);
      List<Ticket> userTickets = ticketsResult.items ?? [];

      if (userTickets.isEmpty) {
        setState(() {
          availableTickets = [];
          _isLoading = false;
        });
        return;
      }

      // Step 2: Get all reviews for the current user
      var reviewFilter = {
        "page": 0,
        "pageSize": 1000, // Get all reviews
        "includeTotalCount": false,
        "userId": UserProvider.currentUser!.id,
      };

      var reviewsResult = await reviewProvider.get(filter: reviewFilter);
      List<Review> userReviews = reviewsResult.items ?? [];

      // Step 3: Get festival IDs that user has already reviewed
      Set<int> reviewedFestivalIds = userReviews
          .map((review) => review.festivalId)
          .toSet();

      // Step 4: Filter tickets to only include those for festivals the user hasn't reviewed
      List<Ticket> unreviewedTickets = userTickets
          .where((ticket) => !reviewedFestivalIds.contains(ticket.festivalId))
          .toList();

      // Step 5: Remove duplicates by festival (keep only one ticket per festival)
      Map<int, Ticket> uniqueFestivalTickets = {};
      for (Ticket ticket in unreviewedTickets) {
        if (!uniqueFestivalTickets.containsKey(ticket.festivalId)) {
          uniqueFestivalTickets[ticket.festivalId] = ticket;
        }
      }

      List<Ticket> uniqueTickets = uniqueFestivalTickets.values.toList();

      // Step 6: Filter by search text if provided
      List<Ticket> filteredTickets = uniqueTickets;
      if (_searchText.isNotEmpty) {
        filteredTickets = uniqueTickets
            .where(
              (ticket) => ticket.festivalTitle.toLowerCase().contains(
                _searchText.toLowerCase(),
              ),
            )
            .toList();
      }

      setState(() {
        availableTickets = filteredTickets;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading available tickets: $e");
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
      reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
      await _loadAvailableTickets();
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
          // Create a festival object from ticket data for the review screen
          final festival = Festival(
            id: ticket.festivalId,
            title: ticket.festivalTitle,
            startDate:
                ticket.createdAt, // Using ticket creation date as fallback
            endDate: ticket.createdAt.add(const Duration(days: 1)), // Fallback
            basePrice: ticket.finalPrice,
            location: null,
            isActive: true,
            cityId: 0,
            cityName: '',
            countryName: '',
            subcategoryId: 0,
            subcategoryName: '',
            categoryName: '',
            organizerId: 0,
            organizerName: '',
            assets: [],
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReviewDetailsScreen(festival: festival),
            ),
          ).then((_) {
            // Return to previous screen
            Navigator.pop(context);
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Festival icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF6A1B9A), const Color(0xFF8E24AA)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.festival,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.festivalTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D1B69),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ticket: ${ticket.ticketTypeName}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Price: ${ticket.finalPrice.toStringAsFixed(2)}\$',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Purchased: ${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Festival'),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
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
            // Search bar
            Container(
              padding: const EdgeInsets.all(20),
              child: Container(
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
                    hintText: "Search festivals...",
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
                    _loadAvailableTickets();
                  },
                ),
              ),
            ),
            // Festivals list
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6A1B9A),
                      ),
                    )
                  : availableTickets.isEmpty
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
                                  color: const Color(
                                    0xFF6A1B9A,
                                  ).withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.festival_outlined,
                              size: 64,
                              color: const Color(0xFF6A1B9A).withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "No festivals found",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D1B69),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "You have no tickets available for review.\nYou may have already reviewed all festivals\nyou have tickets for.",
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
                      onRefresh: _loadAvailableTickets,
                      color: const Color(0xFF6A1B9A),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: availableTickets.length,
                        itemBuilder: (context, index) {
                          return _buildTicketCard(availableTickets[index]);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
