import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; // Add this for cleaner URLs
import 'package:intl/date_symbol_data_local.dart'; // Import for date formatting initialization

import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/auth/login_screen.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/auth/register_screen.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/home/main_screen.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/home/poster_generator_screen.dart';

import 'package:marketing_penerbit_jagaddhita/src/features/admin/product_management_screen.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/add_edit_product_screen.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/global_settings_screen.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/admin_transactions_screen.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/admin_withdrawals_screen.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/admin_user_list_screen.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/catalog/catalog_screen.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/catalog/product_detail_screen.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/auth_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/user_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/product_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/sales_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/wallet_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/notification_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/link_bio_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/customer_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/notification_service.dart' as local;
import 'package:marketing_penerbit_jagaddhita/src/features/sales/sales_entry_book_screen.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/link_bio/link_bio_loading_screen.dart';
import 'firebase_options.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'package:marketing_penerbit_jagaddhita/src/features/notifications/notification_controller.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/storage_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/responsive_web_layout.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/splash/splash_screen.dart'; // Splash Screen Import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: "assets/env"); // Load environment variables
  await initializeDateFormatting('id_ID', null); // Initialize date formatting

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<UserService>(create: (_) => UserService()),
        Provider<ProductService>(create: (_) => ProductService()),
        Provider<SalesService>(create: (_) => SalesService()),
        Provider<CustomerService>(create: (_) => CustomerService()),
        Provider<WalletService>(create: (_) => WalletService()),
        Provider<FirestoreNotificationService>(create: (_) => FirestoreNotificationService()),
        Provider<LinkBioService>(create: (_) => LinkBioService()),
        Provider<local.NotificationService>(create: (_) => local.NotificationService()),
        Provider<StorageService>(create: (_) => StorageService()),
        ChangeNotifierProvider<NotificationController>(
          create: (context) => NotificationController(
            Provider.of<FirestoreNotificationService>(context, listen: false),
            Provider.of<local.NotificationService>(context, listen: false),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jagaddhita Marketing',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Enable System Dark Mode

      routes: {
        // '/': (context) => const SplashScreen(), // Moved to onGenerateRoute
        '/auth_wrapper': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainScreen(),
        '/sales': (context) => const MainScreen(), // alias — web back button after submit sales
        '/sales/book': (context) => const SalesEntryBookScreen(),
        '/catalog': (context) => const CatalogScreen(),
        '/catalog/detail': (context) => const ProductDetailScreen(),
        '/admin': (context) => const MainScreen(),
        '/admin/products': (context) => const ProductManagementScreen(),
        '/admin/products/add': (context) => const AddEditProductScreen(),
        '/admin/settings': (context) => const GlobalSettingsScreen(),
        '/admin/transactions': (context) => const AdminTransactionsScreen(),
        '/admin/withdrawals': (context) => const AdminWithdrawalsScreen(),
        '/admin/users': (context) => const AdminUserListScreen(),
        '/poster_generator': (context) => const PosterGeneratorScreen(),
      },
      onGenerateRoute: (settings) {
        // Debugging Route
        debugPrint('Routing: ${settings.name}');

        final uri = Uri.parse(settings.name ?? '');

        // 1. Check for Bio Link
        if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'bio') {
          if (uri.pathSegments.length > 1) {
            final userId = uri.pathSegments[1];
            final validUser = RegExp(r'^[a-zA-Z0-9_]+$');
            if (userId.isNotEmpty && validUser.hasMatch(userId)) {
              return MaterialPageRoute(
                builder: (context) => LinkBioLoadingScreen(userId: userId),
              );
            }
          }
        }

        // 2. Default to Splash Screen for root '/'
        if (settings.name == '/' || settings.name == null) {
          return MaterialPageRoute(builder: (context) => const SplashScreen());
        }

        // 3. Fallback for unknown routes (to prevent dropping to null/error silently)
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        size: 80,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Halaman Tidak Ditemukan',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rute "${settings.name}" tidak dapat ditemukan di server kami.',
                      style: GoogleFonts.outfit(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/auth_wrapper',
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home_rounded, color: Colors.white),
                      label: const Text('Kembali ke Beranda'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      builder: (context, child) {
        return ResponsiveWebLayout(child: child ?? const SizedBox());
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          return user == null ? const LoginScreen() : const MainScreen();
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
