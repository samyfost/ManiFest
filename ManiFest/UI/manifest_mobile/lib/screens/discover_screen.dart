import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:manifest_mobile/model/festival.dart';
import 'package:manifest_mobile/providers/festival_provider.dart';
import 'package:manifest_mobile/providers/user_provider.dart';
import 'package:provider/provider.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late FestivalProvider festivalProvider;
  Festival? recommended;
  bool _isLoading = false;

  // New state variables for festivals section
  List<Festival> _festivals = [];
  List<String> _categories = [];
  String _selectedCategory = '';
  int _currentFestivalIndex = 0;
  bool _isLoadingFestivals = false;
  final PageController _pageController = PageController();

  Future<void> _loadRecommendation() async {
    if (UserProvider.currentUser == null) return;
    setState(() => _isLoading = true);
    try {
      final userId = UserProvider.currentUser!.id;
      recommended = await festivalProvider.recommend(userId);
    } catch (e) {
      // silent error, keep UI clean
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFestivals() async {
    setState(() => _isLoadingFestivals = true);
    try {
      final result = await festivalProvider.get();
      setState(() {
        _festivals = result.items ?? [];
        _categories = (result.items ?? [])
            .map((f) => f.categoryName)
            .toSet()
            .toList();
        if (_categories.isNotEmpty && _selectedCategory.isEmpty) {
          _selectedCategory = _categories.first;
        }
        _currentFestivalIndex = 0;
      });
    } catch (e) {
      // silent error, keep UI clean
    } finally {
      if (mounted) setState(() => _isLoadingFestivals = false);
    }
  }

  List<Festival> get _filteredFestivals {
    return _festivals
        .where((f) => f.categoryName == _selectedCategory)
        .toList();
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
      _currentFestivalIndex = 0;
    });
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      festivalProvider = Provider.of<FestivalProvider>(context, listen: false);
      await _loadRecommendation();
      await _loadFestivals();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended For You',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF2D1B69),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildRecommendedCard(),
            const SizedBox(height: 32),
            _buildFestivalsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedCard() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: CircularProgressIndicator(color: Color(0xFF6A1B9A)),
        ),
      );
    }
    if (recommended == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6A1B9A).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Text('No recommendation available right now.'),
      );
    }

    final festival = recommended!;
    final imageBytes = (festival.assets.isNotEmpty)
        ? base64Decode(festival.assets.first.base64Content)
        : (festival.logo != null && festival.logo!.isNotEmpty)
        ? base64Decode(festival.logo!)
        : null;
    final flagBytes =
        (festival.countryFlag != null && festival.countryFlag!.isNotEmpty)
        ? base64Decode(festival.countryFlag!)
        : null;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6A1B9A).withOpacity(0.12),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: imageBytes != null
                      ? Image.memory(imageBytes, fit: BoxFit.cover)
                      : const Icon(
                          Icons.festival,
                          size: 64,
                          color: Color(0xFF6A1B9A),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            festival.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D1B69),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (flagBytes != null) ...[
                          const SizedBox(width: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.memory(
                              flagBytes,
                              width: 28,
                              height: 18,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${festival.cityName}, ${festival.countryName}',
                            style: TextStyle(color: Colors.grey[700]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      festival.dateRange,
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A1B9A).withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.category,
                            size: 16,
                            color: Color(0xFF6A1B9A),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '${festival.categoryName} • ${festival.subcategoryName}',
                              style: const TextStyle(
                                color: Color(0xFF6A1B9A),
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Buy Tickets Button
    Positioned(
  bottom: 16,
  right: 16,
  child: SizedBox(
    width: 150,
    height: 40,
    child: FloatingActionButton.extended(
      onPressed: () {
        // TODO: Navigate to ticket purchase
      },
      backgroundColor: const Color(0xFF6A1B9A),
      foregroundColor: Colors.white,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('Discover More'),
          SizedBox(width: 6),
          Icon(Icons.arrow_forward_ios_outlined, size: 18),
        ],
          ),
        ),
      ),
    ),
    ],
    );
  }

  Widget _buildFestivalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore Festivals',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: const Color(0xFF2D1B69),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildCategorySelector(),
        const SizedBox(height: 16),
        _buildFestivalsCarousel(),
      ],
    );
  }

  Widget _buildCategorySelector() {
    if (_categories.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1B9A).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: _categories.map((category) {
          final isSelected = category == _selectedCategory;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6A1B9A)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF6A1B9A).withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _onCategoryChanged(category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF2D1B69),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFestivalsCarousel() {
    if (_isLoadingFestivals) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: CircularProgressIndicator(color: Color(0xFF6A1B9A)),
        ),
      );
    }

    final filteredFestivals = _filteredFestivals;
    if (filteredFestivals.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6A1B9A).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text('No festivals found in ${_selectedCategory} category.'),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 320, // Fixed height for consistent layout
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentFestivalIndex = index;
              });
            },
            itemCount: filteredFestivals.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SingleChildScrollView(
                  child: _buildFestivalCard(filteredFestivals[index]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Page indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            filteredFestivals.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == _currentFestivalIndex
                    ? const Color(0xFF6A1B9A)
                    : Colors.grey[300],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFestivalCard(Festival festival) {
    final imageBytes = (festival.assets.isNotEmpty)
        ? base64Decode(festival.assets.first.base64Content)
        : (festival.logo != null && festival.logo!.isNotEmpty)
        ? base64Decode(festival.logo!)
        : null;
    final flagBytes =
        (festival.countryFlag != null && festival.countryFlag!.isNotEmpty)
        ? base64Decode(festival.countryFlag!)
        : null;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6A1B9A).withOpacity(0.12),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: imageBytes != null
                      ? Image.memory(imageBytes, fit: BoxFit.cover)
                      : const Icon(
                          Icons.festival,
                          size: 64,
                          color: Color(0xFF6A1B9A),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            festival.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D1B69),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (flagBytes != null) ...[
                          const SizedBox(width: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.memory(
                              flagBytes,
                              width: 28,
                              height: 18,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${festival.cityName}, ${festival.countryName}',
                            style: TextStyle(color: Colors.grey[700]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      festival.dateRange,
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A1B9A).withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.category,
                            size: 16,
                            color: Color(0xFF6A1B9A),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '${festival.categoryName} • ${festival.subcategoryName}',
                              style: const TextStyle(
                                color: Color(0xFF6A1B9A),
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Buy Tickets Button for festival cards
Positioned(
  bottom: 16,
  right: 16,
  child: SizedBox(
    width: 150,
    height: 40,
    child: FloatingActionButton.extended(
      onPressed: () {
        // TODO: Navigate to ticket purchase
      },
      backgroundColor: const Color(0xFF6A1B9A),
      foregroundColor: Colors.white,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('Discover More'),
          SizedBox(width: 6),
          Icon(Icons.arrow_forward_ios_outlined, size: 18),
        ],
              ),
          ),
        ),
      ),
    ],
    );
  }
}
