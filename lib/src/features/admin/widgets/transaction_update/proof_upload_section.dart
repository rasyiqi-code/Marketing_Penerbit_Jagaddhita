import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/network_image_web_helper.dart';

class ProofUploadSection extends StatelessWidget {
  final SaleModel sale;
  final String? currentProofUrl;
  final bool hasProof;
  final VoidCallback onUpload;

  const ProofUploadSection({
    super.key,
    required this.sale,
    required this.currentProofUrl,
    required this.hasProof,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    if (hasProof && currentProofUrl != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: NetworkImageWeb(
              imageUrl: currentProofUrl!,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.edit, size: 14),
            label: const Text('Ubah Bukti Transaksi', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
          ),
        ],
      );
    } else {
      final isCod = sale.paymentStatus == SaleModel.statusCod;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isCod ? Colors.orange : Colors.red).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: (isCod ? Colors.orange : Colors.red).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: isCod ? Colors.orange : Colors.red,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  isCod ? 'Bukti Pencairan Ekspedisi Belum Ada' : 'Bukti Pembayaran Belum Ada',
                  style: TextStyle(
                    color: isCod ? Colors.orange : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  isCod
                      ? 'Wajib upload bukti pencairan dana ekspedisi sebelum set ke COMPLETE.'
                      : 'Wajib upload bukti sebelum update ke DP/LUNAS.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ElevatedButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.upload_file, size: 14),
            label: const Text('Upload Bukti Sekarang', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      );
    }
  }
}
