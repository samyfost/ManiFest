import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:manifest_mobile/model/festival.dart';
import 'package:manifest_mobile/model/search_result.dart';
import 'package:manifest_mobile/providers/festival_provider.dart';
import 'package:manifest_mobile/providers/user_provider.dart';
import 'package:manifest_mobile/screens/festival_assets_screen.dart';
import 'package:provider/provider.dart';

class FestivalsListScreen extends StatefulWidget {
  const FestivalsListScreen({super.key});

  @override
  State<FestivalsListScreen> createState() => _FestivalsListScreenState();
}

class _FestivalsListScreenState extends State<FestivalsListScreen> {
  late FestivalProvider _festivalProvider;
  TextEditingController _searchController = TextEditingController();
  SearchResult<Festival>? _festivals;
  bool _isLoading = false;
  String _searchText = '';

  Future<void> _loadFestivals() async {
    if (UserProvider.currentUser == null) return;

    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final result = await _festivalProvider.getWithoutAssets(
        filter: {
          'userIdAttended': UserProvider.currentUser!.id,
          'includeTotalCount': true,
          'page': 0,
          'pageSize': 100,
          if (_searchText.isNotEmpty) 'title': _searchText,
        },
      );
      if (!mounted) return;
      setState(() {
        _festivals = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading festivals: $e'),
          backgroundColor: const Color(0xFF6A1B9A),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _festivalProvider = Provider.of<FestivalProvider>(context, listen: false);
      await _loadFestivals();
    });
  }

  Widget _buildFestivalCard(Festival festival) {
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
              builder: (context) => FestivalAssetsScreen(festival: festival),
            ),
          ).then((_) => _loadFestivals());
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
                  // Logo / Flag
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
                      child: festival.logo != null && festival.logo!.isNotEmpty
                          ? Image.memory(
                              base64Decode(festival.logo!),
                              fit: BoxFit.cover,
                            )
                          : festival.countryFlag != null &&
                                festival.countryFlag!.isNotEmpty
                          ? Image.memory(
                              base64Decode(festival.countryFlag!),
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.flag,
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
                        Text(
                          festival.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D1B69),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${festival.cityName}, ${festival.countryName}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          festival.dateRange,
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
                                FestivalAssetsScreen(festival: festival),
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
                      child: const Text('Contribute Photos'),
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
          // Search bar
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
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search attended festivals...",
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
                      _loadFestivals();
                    },
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6A1B9A)),
                  )
                : _festivals == null || _festivals!.items?.isEmpty == true
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
                            Icons.festival_outlined,
                            size: 64,
                            color: const Color(0xFF6A1B9A).withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "No attended festivals found",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D1B69),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Festivals you've attended will appear here",
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
                    onRefresh: _loadFestivals,
                    color: const Color(0xFF6A1B9A),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: _festivals!.items?.length ?? 0,
                      itemBuilder: (context, index) {
                        return _buildFestivalCard(_festivals!.items![index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
