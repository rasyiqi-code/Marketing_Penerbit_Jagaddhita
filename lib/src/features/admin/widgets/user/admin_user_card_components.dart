import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';

/// Renders category badge for agent (e.g. reseller, distributor).
class AdminCategoryBadge extends StatelessWidget {
  final String? category;

  const AdminCategoryBadge({super.key, this.category});

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color color;
    if (category == 'gold') {
      label = 'RESELLER GOLD';
      color = Colors.amber.shade700;
    } else if (category == 'platinum') {
      label = 'RESELLER PLATINUM';
      color = Colors.blueGrey.shade600;
    } else if (category == 'premium') {
      label = 'RESELLER PREMIUM';
      color = Colors.grey.shade900;
    } else {
      label = 'BELUM DIKELOMPOKKAN';
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Renders main role badge (e.g. marketing, admin).
class AdminRoleBadge extends StatelessWidget {
  final String role;

  const AdminRoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        role.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.primaryColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Header layout displaying agent name, edit button, email, and roles/categories.
class AdminUserHeaderSection extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEdit;

  const AdminUserHeaderSection({
    super.key,
    required this.user,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            (user.name?.isNotEmpty == true)
                                ? user.name!
                                : user.email.split('@')[0],
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            size: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          onPressed: onEdit,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: 16,
                        ),
                      ],
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user.role == 'marketing') ...[
              AdminCategoryBadge(category: user.marketingCategory),
              const SizedBox(width: 8),
            ],
            AdminRoleBadge(role: user.role),
          ],
        ),
      ],
    );
  }
}

/// Section showing bank accounts/details of the user.
class AdminUserBankInfoSection extends StatelessWidget {
  final Map<String, dynamic> bank;

  const AdminUserBankInfoSection({super.key, required this.bank});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.credit_card, size: 14, color: Colors.blue),
              SizedBox(width: 6),
              Text(
                'Banking Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${bank['bank_name']} - ${bank['account_number']}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'A/N ${bank['account_holder']}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Statistics grid (e.g. total sales count & total commission earned)
class AdminUserStatsSection extends StatelessWidget {
  final UserModel user;

  const AdminUserStatsSection({super.key, required this.user});

  Widget _buildVerticalDivider() {
    return Container(
      height: 32,
      width: 1,
      color: Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isCurrency = false,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: isCurrency ? 13 : 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final numberFormat = NumberFormat('#,###');

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          _buildStatItem(
            context,
            'Total Sales',
            numberFormat.format(user.totalSalesCount),
            Icons.shopping_bag_outlined,
            Colors.blue,
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            context,
            'All-Time Earned',
            currencyFormat.format(
              user.totalCommissionEarned + user.totalPulsaEarned,
            ),
            Icons.monetization_on_outlined,
            Colors.green,
            isCurrency: true,
          ),
        ],
      ),
    );
  }
}

/// Balance alert for pending withdrawals/unpaid balance.
class AdminUserBalanceAlertSection extends StatelessWidget {
  final num totalUnpaid;

  const AdminUserBalanceAlertSection({super.key, required this.totalUnpaid});

  @override
  Widget build(BuildContext context) {
    if (totalUnpaid <= 0) return const SizedBox.shrink();

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            'Wait WD Balance:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
          ),
          const Spacer(),
          Text(
            currencyFormat.format(totalUnpaid),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
        ],
      ),
    );
  }
}
