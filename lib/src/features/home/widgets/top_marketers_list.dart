import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/user_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/widgets/async_snapshot_widget.dart';
import 'package:provider/provider.dart';

class TopMarketersList extends StatelessWidget {
  final String currentUserId;

  const TopMarketersList({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Marketers',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<UserModel>>(
          stream: Provider.of<UserService>(
            context,
            listen: false,
          ).getAllMarketingUsers(),
          builder: (context, snapshot) => AsyncSnapshotWidget<List<UserModel>>(
            snapshot: snapshot,
            builder: (context, allUsers) {
              var users = List<UserModel>.from(allUsers);
              // Sort by Total Sales Descending
              users.sort(
                (a, b) => b.totalSalesCount.compareTo(a.totalSalesCount),
              );
              // Take top 5
              final topUsers = users.take(5).toList();

              if (topUsers.isEmpty) {
                return Text(
                  'Belum ada data agen.',
                  style: GoogleFonts.outfit(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              }

              return Column(
                children: topUsers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final agent = entry.value;
                  final isFirst = index == 0;
                  final isMe = agent.id == currentUserId;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe
                          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.15)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isFirst
                            ? Colors.amber.withValues(alpha: 0.5)
                            : (isMe
                                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                                  : Theme.of(context).dividerColor.withValues(alpha: isDark ? 0.05 : 0.1)),
                        width: isFirst || isMe ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: index == 0
                                ? AppTheme.accentColor
                                : (index == 1
                                      ? AppTheme.primaryColor
                                      : (index == 2
                                            ? AppTheme.secondaryColor
                                            : (isDark ? const Color(0xFF334155) : Colors.black.withValues(alpha: 0.05)))),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '#${index + 1}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: index < 3 ? (index == 0 ? Colors.black : Colors.white) : Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Agent Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                agent.name ?? agent.email.split('@')[0],
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                '${agent.totalSalesCount} Penjualan',
                                style: GoogleFonts.outfit(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Medal/Icon for Top 3
                        if (index < 3)
                          Icon(
                            Icons.emoji_events_rounded,
                            color: index == 0
                                ? AppTheme.accentColor
                                : (index == 1 ? AppTheme.primaryColor : AppTheme.secondaryColor),
                            size: 24,
                          ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
