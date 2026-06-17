import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/claim_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/notification_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/notification_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/wallet_service.dart';
import 'package:provider/provider.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/widgets/claim/claim_widgets.dart';

class AdminClaimCard extends StatelessWidget {
  final ClaimModel claim;
  final bool isHistory;
  final WalletService walletService;

  const AdminClaimCard({
    super.key,
    required this.claim,
    required this.isHistory,
    required this.walletService,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final isPulsa = claim.type == ClaimModel.typePulsa;

    // Status config
    Color statusColor = Colors.grey;
    String statusText = claim.status;
    IconData statusIcon = Icons.access_time_rounded;

    if (claim.status == ClaimModel.statusPaid) {
      statusColor = Colors.green;
      statusText = 'BERHASIL';
      statusIcon = Icons.check_circle_rounded;
    } else if (claim.status == ClaimModel.statusRejected) {
      statusColor = Colors.red;
      statusText = 'DITOLAK';
      statusIcon = Icons.cancel_rounded;
    } else {
      statusText = 'MENUNGGU';
    }

    final bankName =
        (isPulsa
            ? (claim.bankDetails['phone'])
            : (claim.bankDetails['bank_name'])) ??
        (claim.bankDetails['info'] ?? '-');

    final accNumber = claim.bankDetails['account_number'];
    final accHolder = claim.bankDetails['account_holder'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // ── Header: Type & Date ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: ClaimHeaderBadge(claim: claim),
          ),
          const Divider(height: 1, thickness: 0.5),

          // ── Body: Amount & Details ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Amount
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Penarikan',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currencyFormat.format(claim.amount),
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (isHistory) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 10, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                statusText,
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Right: Target Info
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Tujuan Transfer',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 2),
                      _buildCopyableText(
                        context,
                        bankName,
                        isBold: true,
                        alignRight: true,
                        isCopyable: claim.bankDetails['info'] != null,
                      ),
                      if (accNumber != null)
                        _buildCopyableText(
                          context,
                          accNumber,
                          alignRight: true,
                          isCopyable: true,
                          color: Colors.black87,
                        ),
                      if (accHolder != null)
                        Text(
                          accHolder.toUpperCase(),
                          textAlign: TextAlign.end,
                          style: GoogleFonts.outfit(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Actions (Only for Requests) ────────────────────────────────────
          if (!isHistory)
            ClaimActionsSection(
              claim: claim,
              onAction: (c, isApprove) async {
                final notificationService = Provider.of<FirestoreNotificationService>(context, listen: false);
                if (isApprove) {
                  await walletService.approveClaim(c.id);
                  final notification = NotificationModel(
                    id: '',
                    title: 'Permintaan Disetujui',
                    body:
                        'Claim ${c.type} sebesar ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(c.amount)} telah dibayar/dikirim.',
                    type: NotificationModel.typeSuccess,
                    recipientId: c.userId,
                    relatedId: c.id,
                    createdAt: DateTime.now(),
                  );
                  await notificationService.sendNotification(notification);
                } else {
                  await walletService.rejectClaim(c);
                  final notification = NotificationModel(
                    id: '',
                    title: 'Permintaan Ditolak',
                    body:
                        'Claim ${c.type} sebesar ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(c.amount)} ditolak.',
                    type: NotificationModel.typeWarning,
                    recipientId: c.userId,
                    relatedId: c.id,
                    createdAt: DateTime.now(),
                  );
                  await notificationService.sendNotification(notification);
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCopyableText(
    BuildContext context,
    String text, {
    bool isBold = false,
    bool alignRight = false,
    bool isCopyable = false,
    Color? color,
  }) {
    if (text.isEmpty) return const SizedBox.shrink();

    Widget content = Text(
      text,
      textAlign: alignRight ? TextAlign.end : TextAlign.start,
      style: TextStyle(
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
        color: color,
        decoration: isCopyable ? TextDecoration.underline : null,
        decorationStyle: TextDecorationStyle.dotted,
      ),
    );

    if (!isCopyable) return content;

    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil disalin: $text'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Tooltip(message: 'Ketuk untuk menyalin', child: content),
    );
  }
}
