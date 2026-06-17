import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/notifications/notification_controller.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/notifications/notification_list_screen.dart';

// New Widgets
import 'package:marketing_penerbit_jagaddhita/src/features/admin/widgets/admin_pending_claims_card.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/widgets/admin_total_agents_card.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/widgets/admin_top_agents_list.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/widgets/admin_recent_transactions_list.dart';

import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/auth_service.dart';
import 'package:provider/provider.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          Consumer<NotificationController>(
            builder: (context, controller, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationListScreen(),
                        ),
                      );
                    },
                  ),
                  if (controller.unreadCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          controller.unreadCount > 9
                              ? '9+'
                              : controller.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(
                    'Konfirmasi Keluar',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                  content: const Text('Apakah Anda yakin ingin keluar dari akun admin?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(
                        'Keluar',
                        style: TextStyle(color: AppTheme.secondaryColor),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await Provider.of<AuthService>(context, listen: false).signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/auth_wrapper', (route) => false);
                }
              }
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Section
                const Row(
                  children: [
                    Expanded(child: AdminPendingClaimsCard()),
                    SizedBox(width: 8),
                    Expanded(child: AdminTotalAgentsCard()),
                  ],
                ),
                const SizedBox(height: 16),

                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transaksi Terkini',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const AdminRecentTransactionsList(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Agen Terbaik',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const AdminTopAgentsList(),
                          ],
                        ),
                      ),
                    ],
                  )
                else ...[
                  // Top Agents Section
                  Text(
                    'Agen Terbaik',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const AdminTopAgentsList(),
                  const SizedBox(height: 16),

                  // Recent Transactions Section
                  Text(
                    'Transaksi Terkini',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const AdminRecentTransactionsList(),
                ],
                const SizedBox(height: 120), // Bottom padding
              ],
            ),
          );
        },
      ),
    );
  }
}
