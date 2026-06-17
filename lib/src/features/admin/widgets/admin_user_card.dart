import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/user_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_dialogs.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/widgets/admin_user_card_components.dart';

class AdminUserCard extends StatelessWidget {
  final UserModel user;
  final UserService userService;

  const AdminUserCard({super.key, required this.user, required this.userService});

  @override
  Widget build(BuildContext context) {
    final totalUnpaid = user.commissionBalance + user.pulsaBalance;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Name & Role Badge
            AdminUserHeaderSection(
              user: user,
              onEdit: () => _showEditAgentDialog(context),
            ),
            const Divider(height: 10, thickness: 0.5),

            // Info Grid (Bank Details)
            if (user.bankDetails != null) ...[
              AdminUserBankInfoSection(bank: user.bankDetails!),
              const SizedBox(height: 4),
            ],

            // Stats Grid
            AdminUserStatsSection(user: user),
            const SizedBox(height: 4),

            // Unpaid Balance Alert
            AdminUserBalanceAlertSection(totalUnpaid: totalUnpaid),
            if (totalUnpaid > 0) const SizedBox(height: 4),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _recalculateStats(context),
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('Recalculate Stats', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => _showDeleteConfirmDialog(context),
                  icon: const Icon(Icons.delete_outline, size: 14),
                  label: const Text('Remove', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          titlePadding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(
            'Edit Agent Info',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              if (user.role == 'marketing') ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<String?>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori Marketing',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: null,
                      child: Text('Belum Dikelompokkan', style: TextStyle(fontSize: 13)),
                    ),
                    DropdownMenuItem(
                      value: 'gold',
                      child: Text('Reseller Gold', style: TextStyle(fontSize: 13)),
                    ),
                    DropdownMenuItem(
                      value: 'platinum',
                      child: Text('Reseller Platinum', style: TextStyle(fontSize: 13)),
                    ),
                    DropdownMenuItem(
                      value: 'premium',
                      child: Text('Reseller Premium', style: TextStyle(fontSize: 13)),
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
              child: const Text('Cancel', style: TextStyle(fontSize: 13)),
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
              child: const Text('Save', style: TextStyle(fontSize: 13)),
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
        AppDialogs.showSuccessSnackBar(context, 'Stats updated successfully!');
      }
    } catch (e) {
      if (context.mounted) {
        AppDialogs.showErrorSnackBar(context, 'Error: $e');
      }
    }
  }

  void _showDeleteConfirmDialog(BuildContext context) async {
    final confirm = await AppDialogs.showConfirmDialog(
      context: context,
      title: 'Delete User?',
      content: 'Are you sure you want to remove marketing agent "${user.name}"?\n\nThis action cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDanger: true,
    );

    if (confirm == true && context.mounted) {
      try {
        await userService.updateAdminUser(user.id, {'role': 'banned'});
        if (context.mounted) {
          AppDialogs.showSuccessSnackBar(context, 'User removed successfully');
        }
      } catch (e) {
        if (context.mounted) {
          AppDialogs.showErrorSnackBar(context, 'Error: $e');
        }
      }
    }
  }
}
