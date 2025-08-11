import 'package:flutter/material.dart';
import 'package:manifest_desktop/layouts/master_screen.dart';
import 'package:manifest_desktop/model/user.dart';
import 'package:manifest_desktop/utils/custom_picture_design.dart';

class UsersDetailsScreen extends StatelessWidget {
  final User user;

  const UsersDetailsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'User Details',
      showBackButton: true,
      child: _buildUserDetails(context),
    );
  }

  Widget _buildUserDetails(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button and title
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Go back',
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.person_outline, size: 32, color: Colors.blue),
                    const SizedBox(width: 16),
                    Text(
                      'User Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Profile picture and basic info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile picture
                    CustomPictureDesign(
                      base64: user.picture,
                      size: 120,
                      fallbackIcon: Icons.person,
                      borderColor: Colors.blue,
                      iconColor: Colors.blue,
                      backgroundColor: const Color(0xFFE3F2FD),
                    ),
                    const SizedBox(width: 24),

                    // Basic user info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${user.firstName} ${user.lastName}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '@${user.username}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Status indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: user.isActive
                                  ? Colors.green[100]
                                  : Colors.red[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: user.isActive
                                    ? Colors.green
                                    : Colors.red,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  user.isActive
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: user.isActive
                                      ? Colors.green
                                      : Colors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  user.isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    color: user.isActive
                                        ? Colors.green[700]
                                        : Colors.red[700],
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

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 24),

                // Detailed information grid
                _buildInfoGrid(),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),

                // Roles section
                _buildRolesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact & Personal Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.email_outlined,
                label: 'Email',
                value: user.email,
                iconColor: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: user.phoneNumber ?? 'Not provided',
                iconColor: Colors.green,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.location_city_outlined,
                label: 'City',
                value: user.cityName,
                iconColor: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.person_outline,
                label: 'Gender',
                value: user.genderName,
                iconColor: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildRolesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Roles & Permissions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 16),

        if (user.roles.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  'No roles assigned',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: user.roles.map((role) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue, width: 1),
                ),
                child: Text(
                  role.name,
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
