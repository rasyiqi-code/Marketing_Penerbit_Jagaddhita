import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/claim_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/notification_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/wallet_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';

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
    final notificationService = Provider.of<AppNotificationService>(context, listen: false);
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
          // Header: Type & Date
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isPulsa
                        ? Colors.blue.shade50
                        : Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPulsa
                            ? Icons.phone_android_rounded
                            : Icons.account_balance_rounded,
                        size: 11,
                        color: isPulsa ? Colors.blue : Colors.purple,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPulsa ? 'PULSA' : 'TRANSFER BANK',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isPulsa
                              ? Colors.blue.shade700
                              : Colors.purple.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(claim.createdAt),
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),

          // Body: Amount & Details
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

          // Actions (Only for Requests)
          if (!isHistory) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmAction(
                        context,
                        'Tolak',
                        'Saldo akan dikembalikan ke user. Lanjutkan?',
                        () async {
                          await walletService.rejectClaim(claim);

                          // Notify
                          final notification = NotificationModel(
                            id: '',
                            title: 'Permintaan Ditolak',
                            body:
                                'Claim ${claim.type} sebesar ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(claim.amount)} ditolak.',
                            type: NotificationModel.typeWarning,
                            recipientId: claim.userId,
                            relatedId: claim.id,
                            createdAt: DateTime.now(),
                          );
                          await notificationService.sendNotification(notification);
                        },
                        Colors.red,
                      ),
                      icon: const Icon(Icons.close_rounded, size: 14),
                      label: const Text('Tolak'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        side: BorderSide(color: Colors.red.shade200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmAction(
                        context,
                        'Setujui',
                        'Pastikan Anda sudah transfer dana/pulsa. Lanjutkan?',
                        () async {
                          await walletService.approveClaim(claim.id);

                          // Notify
                          final notification = NotificationModel(
                            id: '',
                            title: 'Permintaan Disetujui',
                            body:
                                'Claim ${claim.type} sebesar ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(claim.amount)} telah dibayar/dikirim.',
                            type: NotificationModel.typeSuccess,
                            recipientId: claim.userId,
                            relatedId: claim.id,
                            createdAt: DateTime.now(),
                          );
                          await notificationService.sendNotification(notification);
                        },
                        Colors.green,
                      ),
                      icon: const Icon(Icons.check_rounded, size: 14),
                      label: const Text('Bayar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

  void _confirmAction(
    BuildContext context,
    String action,
    String message,
    Future<void> Function() onConfirm,
    Color color,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text('Konfirmasi $action', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await onConfirm();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Permintaan $action berhasil diproses'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.pop(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Konfirmasi', style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
