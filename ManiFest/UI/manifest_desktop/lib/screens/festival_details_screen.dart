import 'package:flutter/material.dart';
import 'package:manifest_desktop/layouts/master_screen.dart';
import 'package:manifest_desktop/model/festival.dart';
import 'package:manifest_desktop/utils/base_map.dart';

class FestivalDetailsScreen extends StatefulWidget {
  final Festival festival;

  const FestivalDetailsScreen({super.key, required this.festival});

  @override
  State<FestivalDetailsScreen> createState() => _FestivalDetailsScreenState();
}

class _FestivalDetailsScreenState extends State<FestivalDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Festival Details',
      showBackButton: true,
      child: _buildFestivalDetails(),
    );
  }

  Widget _buildFestivalDetails() {
    final festival = widget.festival;
    final coordinates = festival.coordinates;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Keep the original header
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Icon(
                    Icons.festival,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          festival.title,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          festival.dateRange,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: festival.isActive ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      festival.isActive ? 'Active' : 'Inactive',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // New layout: Map on left, info on right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Map
              Expanded(
                flex: 1,
                child: _buildInfoCard(
                  'Festival Location',
                  Icons.map,
                  [],
                  child: coordinates != null
                      ? BaseMap(
                          start: festival.location,
                          end: festival.location,
                          height: 300,
                          width: double.infinity,
                          showRouteInfoOverlay: false,
                          showZoomControls: true,
                          title: 'Festival Location',
                          accentColor: Theme.of(context).colorScheme.primary,
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Location coordinates not available',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 24),

              // Right side - All information in one card
              Expanded(
                flex: 2,
                child:
                    _buildInfoCard('Festival Information', Icons.info_outline, [
                      _buildInfoRow('Title', festival.title),
                      _buildInfoRow('Date Range', festival.dateRange),
                      _buildInfoRow(
                        'Base Price',
                        '\$${festival.basePrice.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 7),
                      const Divider(),

                      _buildInfoRow('City', festival.cityName),
                      _buildInfoRow('Country', festival.countryName),
                      _buildInfoRow('Organizer', festival.organizerName),
                      const SizedBox(height: 7),
                      const Divider(),
                      _buildInfoRow('Subcategory', festival.subcategoryName),
                      _buildInfoRow('Category', festival.categoryName),
                      const SizedBox(height: 7),
                    ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    IconData icon,
    List<Widget> infoRows, {
    Widget? child,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (child != null) child else ...infoRows,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
