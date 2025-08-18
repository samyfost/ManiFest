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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      festivalProvider = Provider.of<FestivalProvider>(context, listen: false);
      await _loadRecommendation();
    });
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

    return Container(
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
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
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
                      Text(
                        '${festival.categoryName} • ${festival.subcategoryName}',
                        style: const TextStyle(
                          color: Color(0xFF6A1B9A),
                          fontWeight: FontWeight.w600,
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
    );
  }
}
