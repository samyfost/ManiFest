import 'package:flutter/material.dart';
import 'package:manifest_desktop/providers/auth_provider.dart';
import 'package:manifest_desktop/providers/city_provider.dart';
import 'package:manifest_desktop/providers/country_provider.dart';
import 'package:manifest_desktop/providers/category_provider.dart';
import 'package:manifest_desktop/providers/subcategory_provider.dart';
import 'package:manifest_desktop/providers/user_provider.dart';
import 'package:manifest_desktop/providers/organizer_provider.dart';
import 'package:manifest_desktop/providers/ticket_type_provider.dart';
import 'package:manifest_desktop/providers/gender_provider.dart';
import 'package:manifest_desktop/providers/festival_provider.dart';
import 'package:manifest_desktop/providers/asset_provider.dart';
import 'package:manifest_desktop/providers/review_provider.dart';
import 'package:manifest_desktop/providers/ticket_provider.dart';
import 'package:manifest_desktop/providers/subcategory_provider.dart';
import 'package:manifest_desktop/screens/city_list_screen.dart';
import 'package:manifest_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CityProvider>(
          create: (context) => CityProvider(),
        ),
        ChangeNotifierProvider<CountryProvider>(
          create: (context) => CountryProvider(),
        ),
        ChangeNotifierProvider<CategoryProvider>(
          create: (context) => CategoryProvider(),
        ),
        ChangeNotifierProvider<SubcategoryProvider>(
          create: (context) => SubcategoryProvider(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProvider<OrganizerProvider>(
          create: (context) => OrganizerProvider(),
        ),
        ChangeNotifierProvider<TicketTypeProvider>(
          create: (context) => TicketTypeProvider(),
        ),
        ChangeNotifierProvider<GenderProvider>(
          create: (context) => GenderProvider(),
        ),
        ChangeNotifierProvider<FestivalProvider>(
          create: (context) => FestivalProvider(),
        ),
        ChangeNotifierProvider<AssetProvider>(
          create: (context) => AssetProvider(),
        ),
        ChangeNotifierProvider<ReviewProvider>(
          create: (context) => ReviewProvider(),
        ),
        ChangeNotifierProvider<TicketProvider>(
          create: (context) => TicketProvider(),
        ),
        ChangeNotifierProvider<SubcategoryProvider>(
          create: (context) => SubcategoryProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ManiFest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A1B9A), // Purple
          primary: const Color(0xFF6A1B9A), // Purple
        ),
        useMaterial3: true,
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image with overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/login_background.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          // Main content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 440),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Card(
                  elevation: 24,
                  shadowColor: Colors.black.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  color: Colors.white.withOpacity(0.95),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.95),
                          Colors.white.withOpacity(0.9),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo with subtle animation
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 800),
                            tween: Tween(begin: 0.8, end: 1.0),
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 4,
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    "assets/images/logo_large.png",
                                    height: 120,
                                    width: 120,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),

                          // Welcome text
                          Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Sign in to your ManiFest account",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Username field
                          TextField(
                            controller: usernameController,
                            decoration: customTextFieldDecoration(
                              "Username",
                              prefixIcon: Icons.person_outline,
                              hintText: "Enter your username",
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Password field
                          TextField(
                            controller: passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration:
                                customTextFieldDecoration(
                                  "Password",
                                  prefixIcon: Icons.lock_outline,
                                  hintText: "Enter your password",
                                  suffixIcon: _isPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFF6B7280),
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                          ),
                          const SizedBox(height: 32),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A1B9A),
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: const Color(
                                  0xFF6A1B9A,
                                ).withOpacity(0.3),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      "Sign In",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Forgot password link
                          TextButton(
                            onPressed: () {
                              // Add forgot password functionality
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: const Color(0xFF6A1B9A),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final username = usernameController.text;
      final password = passwordController.text;

      // Set basic auth for subsequent requests
      AuthProvider.username = username;
      AuthProvider.password = password;

      // Authenticate and set current user
      final userProvider = context.read<UserProvider>();
      final user = await userProvider.authenticate(username, password);

      if (user != null) {
        // Check if user has admin role (roleId = 1)
        bool hasAdminRole = user.roles.any((role) => role.id == 1);

        print(
          "User roles: ${user.roles.map((r) => '${r.name} (ID: ${r.id})').join(', ')}",
        );
        print("Has admin role: $hasAdminRole");

        if (hasAdminRole) {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CityListScreen(),
                settings: const RouteSettings(name: 'CityListScreen'),
              ),
            );
          }
        } else {
          if (mounted) {
            _showAccessDeniedDialog();
          }
        }
      } else {
        if (mounted) {
          _showErrorDialog("Invalid username or password.");
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
      }
    } catch (e) {
      print(e);
      if (mounted) {
        _showErrorDialog("An unexpected error occurred. Please try again.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Color(0xFFE53E3E)),
            SizedBox(width: 8),
            Text("Login Failed"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6A1B9A),
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showAccessDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Color(0xFFE53E3E)),
            SizedBox(width: 8),
            Text("Access Denied"),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You do not have administrator privileges.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            Text(
              "This application is restricted to administrators only. Please contact your system administrator if you believe you should have access.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Clear the form and reset state
              usernameController.clear();
              passwordController.clear();
              // Clear authentication credentials
              AuthProvider.username = '';
              AuthProvider.password = '';
              setState(() {
                _isLoading = false;
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6A1B9A),
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
