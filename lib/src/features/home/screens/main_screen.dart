import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/user_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/notifications/controllers/notification_controller.dart';

// Screens
import 'package:marketing_penerbit_jagaddhita/src/features/home/screens/home_screen.dart'; // Marketing Home
import 'package:marketing_penerbit_jagaddhita/src/features/link_bio/screens/link_bio_screen.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/catalog/screens/catalog_screen.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/profile/profile_screen.dart';

// Admin Screens
import 'package:marketing_penerbit_jagaddhita/src/features/admin/screens/product_management_screen.dart'; // Manage Catalog
import 'package:marketing_penerbit_jagaddhita/src/features/admin/screens/admin_home_screen.dart'; // NEW Admin Home

// Widgets
import 'package:marketing_penerbit_jagaddhita/src/features/home/widgets/navigation/main_bottom_nav_bar.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/home/widgets/navigation/marketing_fab_menu.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/home/widgets/navigation/admin_fab_menu.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return StreamBuilder<UserModel>(
      stream: Provider.of<UserService>(
        context,
        listen: false,
      ).getUserStream(user.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // If permission denied (likely logout race condition), show loading while AuthWrapper redirects
          if (snapshot.error.toString().contains('permission-denied')) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading profile: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Coba Lagi'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userModel = snapshot.data!;
        
        if (userModel.role == 'banned') {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.block, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Akun Anda Ditangguhkan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Silakan hubungi administrator.'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    child: const Text('Keluar'),
                  ),
                ],
              ),
            ),
          );
        }

        final isAdmin = userModel.role == 'admin';

        // Initialize Notification Listener
        Provider.of<NotificationController>(
          context,
          listen: false,
        ).listenToNotifications(userModel.id, isAdmin: isAdmin);

        final pages = isAdmin ? _getAdminPages() : _getMarketingPages();

        // Ensure index is valid when switching roles or pages change count
        if (_currentIndex >= pages.length) {
          _currentIndex = 0;
        }

        return Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (isAdmin) {
                _showAdminFabMenu(context);
              } else {
                _showMarketingFabMenu(context);
              }
            },
            backgroundColor: AppTheme.primaryColor,
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 36),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: MainBottomNavigationBar(
            currentIndex: _currentIndex,
            isAdmin: isAdmin,
            onTap: (index) => setState(() => _currentIndex = index),
          ),
        );
      },
    );
  }

  List<Widget> _getMarketingPages() {
    return [
      const HomeScreen(), // 1. Home (Wallet & Stats)
      const LinkBioScreen(), // 2. Link Bio
      const CatalogScreen(), // 4. Catalog (Item 3 is FAB)
      const ProfileScreen(), // 5. Profile
    ];
  }

  List<Widget> _getAdminPages() {
    return [
      const AdminHomeScreen(), // 1. Admin Home (Stats & Quick Access)
      const LinkBioScreen(), // 2. Manage Bio (Reuse for now)
      const ProductManagementScreen(), // 4. Manage Catalog
      const ProfileScreen(), // 5. Profile
    ];
  }

  void _showMarketingFabMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const MarketingFabMenu(),
    );
  }

  void _showAdminFabMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const AdminFabMenu(),
    );
  }
}
