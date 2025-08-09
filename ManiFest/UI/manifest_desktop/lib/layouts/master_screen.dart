
import 'package:flutter/material.dart';
import 'package:manifest_desktop/main.dart';
import 'package:manifest_desktop/screens/city_list_screen.dart';


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

class _MasterScreenState extends State<MasterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (widget.showBackButton) ...[
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              SizedBox(width: 8),
            ],
            Text(widget.title),
          ],
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Color(0xFFF7F7F7),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
          
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                    child: Text(
                      'ManiFest Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.8),
                            offset: Offset(2, 3),
                          ),
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black.withOpacity(0.6),
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              

              _drawerTile(
                context,
                icon: Icons.location_city,
                label: 'Cities',
                screen: CityListScreen(),
              ),

              Divider(),
              _logoutTile(context),
            ],
          ),
        ),
      ),
      body: widget.child,
    );
  }
}

Widget _drawerTile(
  BuildContext context, {
  required IconData icon,
  required String label,
  required Widget screen,
}) {
  final isSelected =
      ModalRoute.of(context)?.settings.name == screen.runtimeType.toString();
  return Material(
    color: isSelected ? Color(0xFFFFF3E0) : Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(8),
      hoverColor: Color(0xFFFFF8E1),
      mouseCursor: SystemMouseCursors.click, // <-- Use click, not grab
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Color(0xFFFF9800) : Colors.grey[800],
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Color(0xFFFF9800) : Colors.grey[900],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}

Widget _logoutTile(BuildContext context) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(8),
      hoverColor: Colors.red[50],
      mouseCursor: SystemMouseCursors.click, // <-- Use click, not grab
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      },
      child: ListTile(
        leading: Icon(Icons.logout, color: Colors.red[700]),
        title: Text('Logout', style: TextStyle(color: Colors.red[700])),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
