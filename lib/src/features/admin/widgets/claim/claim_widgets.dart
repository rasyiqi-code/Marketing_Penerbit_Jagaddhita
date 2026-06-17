import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/claim_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';

/// Badge header untuk menampilkan tipe claim (PULSA / TRANSFER BANK) dan tanggal.
class ClaimHeaderBadge extends StatelessWidget {
  final ClaimModel claim;

  const ClaimHeaderBadge({super.key, required this.claim});

  @override
  Widget build(BuildContext context) {
    final isPulsa = claim.type == ClaimModel.typePulsa;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isPulsa ? Colors.blue.shade50 : Colors.purple.shade50,
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
                  color: isPulsa ? Colors.blue.shade700 : Colors.purple.shade700,
                ),
              ),
            ],
          ),
        ),
        Text(
          DateFormat('dd MMM yyyy, HH:mm').format(claim.createdAt),
          style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey[500]),
        ),
      ],
    );
  }
}

/// Tombol aksi Tolak / Bayar untuk admin pada klaim yang masih pending.
class ClaimActionsSection extends StatelessWidget {
  final ClaimModel claim;
  final Future<void> Function(ClaimModel, bool isApprove) onAction;

  const ClaimActionsSection({
    super.key,
    required this.claim,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _confirmAction(context, isApprove: false),
              icon: const Icon(Icons.close_rounded, size: 14),
              label: const Text('Tolak'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 6),
                side: BorderSide(color: Colors.red.shade200),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _confirmAction(context, isApprove: true),
              icon: const Icon(Icons.check_rounded, size: 14),
              label: const Text('Bayar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 6),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmAction(BuildContext context, {required bool isApprove}) {
    final action = isApprove ? 'Setujui' : 'Tolak';
    final message = isApprove
        ? 'Pastikan Anda sudah transfer dana/pulsa. Lanjutkan?'
        : 'Saldo akan dikembalikan ke user. Lanjutkan?';
    final color = isApprove ? Colors.green : Colors.red;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text(
          'Konfirmasi $action',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Text(message, style: const TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await onAction(claim, isApprove);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Permintaan $action berhasil diproses'),
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
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Konfirmasi',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
