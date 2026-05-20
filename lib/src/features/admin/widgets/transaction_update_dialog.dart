import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/notification_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/sales_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/notification_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/storage_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/network_image_web_helper.dart';
import 'package:provider/provider.dart';

class TransactionUpdateDialog extends StatefulWidget {
  final SaleModel sale;

  const TransactionUpdateDialog({super.key, required this.sale});

  static Future<void> show(BuildContext context, SaleModel sale) {
    return showDialog(
      context: context,
      builder: (context) => TransactionUpdateDialog(sale: sale),
    );
  }

  @override
  State<TransactionUpdateDialog> createState() =>
      _TransactionUpdateDialogState();
}

class _TransactionUpdateDialogState extends State<TransactionUpdateDialog> {
  final TextEditingController _noteController = TextEditingController();
  String? _currentProofUrl;
  bool _hasProof = false;

  @override
  void initState() {
    super.initState();
    _currentProofUrl = widget.sale.transactionProofUrl;
    _hasProof = _currentProofUrl != null;

    if (widget.sale.paymentStatus == SaleModel.statusDp && _hasProof) {
      // Check if proof was uploaded DURING the DP phase
      final hasUploadDuringDp = widget.sale.history.any(
        (h) =>
            h.status == SaleModel.statusDp && h.note == 'Admin uploaded proof',
      );
      _hasProof = hasUploadDuringDp;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<String?> _uploadProofForSale(SaleModel sale, {String? oldUrl}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      try {
        if (!mounted) return null;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Mengunggah bukti...')));

        final storage = Provider.of<StorageService>(context, listen: false);
        final bytes = await picked.readAsBytes();
        final filename =
            'proof_admin_${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
        final url = await storage.uploadBytes(bytes, filename, 'transactions');

        if (!mounted) return null;

        // Update Sale Document Immediately
        await Provider.of<SalesService>(
          context,
          listen: false,
        ).updateSaleStatus(
          sale,
          sale.paymentStatus, // Keep status same
          note: 'Admin uploaded proof',
          actor: 'Admin',
          extraData: {'transaction_proof_url': url},
        );

        // Delete old file if exists
        if (oldUrl != null && oldUrl != url) {
          storage.deleteFileByUrl(oldUrl);
        }

        if (!mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bukti berhasil diunggah!')),
        );
        // Navigator.pop(context); // Don't close dialog
        return url;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal upload: $e')));
        }
        return null;
      }
    }
    return null;
  }

  Future<void> _updateStatus(
    SaleModel sale,
    String newStatus, {
    String? note,
  }) async {
    try {
      final salesService = Provider.of<SalesService>(context, listen: false);
      final notificationService = Provider.of<AppNotificationService>(context, listen: false);

      final Map<String, dynamic> extraData = {};
      if (newStatus == SaleModel.statusLunas ||
          newStatus == SaleModel.statusComplete) {
        extraData['paid_amount'] = sale.totalPrice;
      }

      await salesService.updateSaleStatus(
        sale,
        newStatus,
        note: note,
        actor: 'Admin',
        extraData: extraData,
      );

      // Trigger Notification
      final notification = NotificationModel(
        id: '',
        title: 'Update Status Transaksi',
        body:
            'Status transaksi #${sale.id.substring(0, 8).toUpperCase()} berubah menjadi $newStatus',
        type: newStatus == SaleModel.statusProblem
            ? NotificationModel.typeWarning
            : NotificationModel.typeSuccess,
        recipientId: sale.userId,
        relatedId: sale.id,
        createdAt: DateTime.now(),
      );

      await notificationService.sendNotification(notification);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status berhasil diubah jadi $newStatus')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: const Text('Perbarui Transaksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Proof Section
          if (_hasProof && _currentProofUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: NetworkImageWeb(
                imageUrl: _currentProofUrl!,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: () async {
                final newUrl = await _uploadProofForSale(
                  widget.sale,
                  oldUrl: _currentProofUrl,
                );
                if (newUrl != null) {
                  setState(() {
                    _currentProofUrl = newUrl;
                    _hasProof = true;
                  });
                }
              },
              icon: const Icon(Icons.edit, size: 14),
              label: const Text('Ubah Bukti Transaksi', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Bukti Pembayaran Belum Ada',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Wajib upload bukti sebelum update ke DP/LUNAS.',
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
              onPressed: () async {
                final newUrl = await _uploadProofForSale(
                  widget.sale,
                  oldUrl: _currentProofUrl,
                );
                if (newUrl != null) {
                  setState(() {
                    _currentProofUrl = newUrl;
                    _hasProof = true;
                  });
                }
              },
              icon: const Icon(Icons.upload_file, size: 14),
              label: const Text('Upload Bukti Sekarang', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
          const Divider(height: 16),

          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Catatan / Alasan (Opsional)',
              hintText: 'Contoh: Pembayaran oke...',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              labelStyle: TextStyle(fontSize: 12),
              hintStyle: TextStyle(fontSize: 12),
            ),
            style: const TextStyle(fontSize: 13),
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          if (widget.sale.paymentStatus == SaleModel.statusPending)
            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: EdgeInsets.zero,
              title: const Text('Tandai sebagai DP', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: !_hasProof
                  ? const Text(
                      'Wajib bukti foto!',
                      style: TextStyle(color: Colors.red, fontSize: 11),
                    )
                  : null,
              enabled: _hasProof,
              onTap: () {
                Navigator.pop(context);
                _updateStatus(
                  widget.sale,
                  SaleModel.statusDp,
                  note: _noteController.text,
                );
              },
            ),
          if (widget.sale.paymentStatus == SaleModel.statusPending ||
              widget.sale.paymentStatus == SaleModel.statusDp) ...[
            const Divider(height: 8),
            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: EdgeInsets.zero,
              title: const Text('Tandai LUNAS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: Text(
                !_hasProof
                    ? 'Wajib bukti foto!'
                    : 'Status LUNAS belum mencairkan bonus. Bonus cair saat status COMPLETE.',
                style: TextStyle(
                  color: !_hasProof ? Colors.red : Colors.grey[600],
                  fontSize: 11,
                ),
              ),
              trailing: Icon(
                Icons.check_circle,
                color: _hasProof ? Colors.green : Colors.grey,
                size: 20,
              ),
              enabled: _hasProof,
              onTap: () {
                Navigator.pop(context);
                _updateStatus(
                  widget.sale,
                  SaleModel.statusLunas,
                  note: _noteController.text,
                );
              },
            ),
          ],
          if (widget.sale.paymentStatus == SaleModel.statusLunas) ...[
            const Divider(height: 8),
            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: EdgeInsets.zero,
              title: const Text('Tandai SELESAI (COMPLETE)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: const Text('Pesanan diterima/selesai.', style: TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.done_all, color: Colors.purple, size: 20),
              onTap: () {
                Navigator.pop(context);
                _updateStatus(
                  widget.sale,
                  SaleModel.statusComplete,
                  note: _noteController.text,
                );
              },
            ),
          ],
          const Divider(height: 8),
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: EdgeInsets.zero,
            title: const Text('Tandai BERMASALAH', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.red)),
            subtitle: const Text('Ada masalah pembayaran/pesanan.', style: TextStyle(fontSize: 11)),
            trailing: const Icon(Icons.report_problem, color: Colors.red, size: 20),
            textColor: Colors.red,
            onTap: () {
              if (_noteController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wajib isi catatan masalahnya ya'),
                  ),
                );
                return;
              }
              Navigator.pop(context);
              _updateStatus(
                widget.sale,
                SaleModel.statusProblem,
                note: _noteController.text,
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}
