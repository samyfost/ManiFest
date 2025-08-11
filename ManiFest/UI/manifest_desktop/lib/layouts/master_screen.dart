import 'package:flutter/material.dart';
import 'package:manifest_desktop/main.dart';
import 'package:manifest_desktop/screens/city_list_screen.dart';
import 'package:manifest_desktop/screens/country_list_screen.dart';
import 'package:manifest_desktop/screens/category_list_screen.dart';
import 'package:manifest_desktop/screens/subcategory_list_screen.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({
    super.key,
    required this.child,
    required this.title,
    this.showBackButton = false,
  });
  final Widget child;
  final String title;
  final bool showBackButton;

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.grey.withOpacity(0.1),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6A1B9A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.menu_rounded,
                color: Color(0xFF6A1B9A),
                size: 20,
              ),
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
              _animationController?.forward();
            },
          ),
        ),
        title: Row(
          children: [
            if (widget.showBackButton) ...[
              Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF374151),
                    size: 18,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'ManiFest Admin Panel',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF6A1B9A),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        width: 280,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: _slideAnimation != null
            ? AnimatedBuilder(
                animation: _slideAnimation!,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_slideAnimation!.value * 280, 0),
                    child: _buildDrawerContent(),
                  );
                },
              )
            : _buildDrawerContent(),
      ),
      body: Container(margin: const EdgeInsets.all(16), child: widget.child),
    );
  }

  Widget _buildDrawerContent() {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 16, right: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1B9A).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Image.asset(
                    "assets/images/logo_large.png",
                    height: 50,
                    width: 50,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ManiFest',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Navigation section - Scrollable
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _modernDrawerTile(
                      context,
                      icon: Icons.location_city_outlined,
                      activeIcon: Icons.location_city_rounded,
                      label: 'Cities',
                      screen: CityListScreen(),
                    ),
                    const SizedBox(height: 8),
                    _modernDrawerTile(
                      context,
                      icon: Icons.flag_outlined,
                      activeIcon: Icons.flag,
                      label: 'Countries',
                      screen: CountryListScreen(),
                    ),
                    const SizedBox(height: 8),
                    _modernDrawerTile(
                      context,
                      icon: Icons.category_outlined,
                      activeIcon: Icons.category,
                      label: 'Categories',
                      screen: CategoryListScreen(),
                    ),
                    const SizedBox(height: 8),
                    _modernDrawerTile(
                      context,
                      icon: Icons.view_list_outlined,
                      activeIcon: Icons.view_list,
                      label: 'Subcategories',
                      screen: SubcategoryListScreen(),
                    ),
                    // Add more tiles here in the future
                  ],
                ),
              ),
            ),
          ),

          // Bottom section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
                const SizedBox(height: 8),
                _modernLogoutTile(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _modernDrawerTile(
  BuildContext context, {
  required IconData icon,
  required IconData activeIcon,
  required String label,
  required Widget screen,
}) {
  final currentRoute = ModalRoute.of(context)?.settings.name;
  final screenRoute = screen.runtimeType.toString();

  // Get the current screen type from the route
  bool isSelected = false;

  if (label == 'Cities') {
    // Matches exactly CityListScreen or CityDetailsScreen
    isSelected =
        currentRoute == 'CityListScreen' ||
        currentRoute == 'CityDetailsScreen' ||
        (currentRoute == null &&
            (screen.runtimeType.toString() == 'CityListScreen' ||
                screen.runtimeType.toString() == 'CityDetailsScreen'));
  } else if (label == 'Countries') {
    // Matches exactly CountryListScreen or CountryDetailsScreen
    isSelected =
        currentRoute == 'CountryListScreen' ||
        currentRoute == 'CountryDetailsScreen' ||
        (currentRoute == null &&
            (screen.runtimeType.toString() == 'CountryListScreen' ||
                screen.runtimeType.toString() == 'CountryDetailsScreen'));
  } else if (label == 'Categories') {
    // Matches exactly CategoryListScreen or CategoryDetailsScreen
    isSelected =
        currentRoute == 'CategoryListScreen' ||
        currentRoute == 'CategoryDetailsScreen' ||
        (currentRoute == null &&
            (screen.runtimeType.toString() == 'CategoryListScreen' ||
                screen.runtimeType.toString() == 'CategoryDetailsScreen'));
  } else if (label == 'Subcategories') {
    // Matches exactly SubcategoryListScreen or SubcategoryDetailsScreen
    isSelected =
        currentRoute == 'SubcategoryListScreen' ||
        currentRoute == 'SubcategoryDetailsScreen' ||
        (currentRoute == null &&
            (screen.runtimeType.toString() == 'SubcategoryListScreen' ||
                screen.runtimeType.toString() == 'SubcategoryDetailsScreen'));
  }

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 2),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => screen,
              settings: RouteSettings(name: screenRoute),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                : null,
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey(isSelected),
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _modernLogoutTile(BuildContext context) {
  return Container(
    width: double.infinity,
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _showLogoutDialog(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.white, size: 22),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Icon(Icons.exit_to_app_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    ),
  );
}

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFF6A1B9A)),
            SizedBox(width: 12),
            Text('Confirm Logout'),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout from your account?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B9A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      );
    },
  );
}
