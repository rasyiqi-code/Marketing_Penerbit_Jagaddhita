import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/user_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/widgets/admin_user_card_components.dart';

class AdminUserCard extends StatelessWidget {
  final UserModel user;
  final UserService userService;

  const AdminUserCard({super.key, required this.user, required this.userService});

  @override
  Widget build(BuildContext context) {
    final totalUnpaid = user.commissionBalance + user.pulsaBalance;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Name & Role Badge
            AdminUserHeaderSection(
              user: user,
              onEdit: () => _showEditAgentDialog(context),
            ),
            const Divider(height: 24),

            // Info Grid (Bank Details)
            if (user.bankDetails != null) ...[
              AdminUserBankInfoSection(bank: user.bankDetails!),
              const SizedBox(height: 16),
            ],

            // Stats Grid
            AdminUserStatsSection(user: user),
            const SizedBox(height: 12),

            // Unpaid Balance Alert
            AdminUserBalanceAlertSection(totalUnpaid: totalUnpaid),
            const SizedBox(height: 16),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _recalculateStats(context),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Recalculate Stats'),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => _showDeleteConfirmDialog(context),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Remove'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAgentDialog(BuildContext context) {
    final nameController = TextEditingController(text: user.name);
    String? selectedCategory = user.marketingCategory;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Agent Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              if (user.role == 'marketing') ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori Marketing',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: null,
                      child: Text('Belum Dikelompokkan'),
                    ),
                    DropdownMenuItem(
                      value: 'reseller',
                      child: Text('Reseller (20%)'),
                    ),
                    DropdownMenuItem(
                      value: 'distributor',
                      child: Text('Distributor (35%)'),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      selectedCategory = val;
                    });
                  },
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await userService.updateAdminUser(user.id, {
                    'name': nameController.text.trim(),
                    'marketing_category': selectedCategory,
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Agent info updated')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _recalculateStats(BuildContext context) async {
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Recalculating stats...')));
      await userService.recalculateUserStats(user.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stats updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User?'),
        content: Text(
          'Are you sure you want to remove marketing agent "${user.name}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await userService.deleteUser(user.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User removed successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
