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
  final TextEditingController _courierController = TextEditingController();
  final TextEditingController _resiController = TextEditingController();
  String? _selectedShippingStatus;
  String? _currentProofUrl;
  bool _hasProof = false;

  @override
  void initState() {
    super.initState();
    _currentProofUrl = widget.sale.transactionProofUrl;
    _hasProof = _currentProofUrl != null;

    _selectedShippingStatus = widget.sale.shippingStatus;
    _courierController.text = widget.sale.shippingCourier ?? '';
    _resiController.text = widget.sale.shippingResi ?? '';

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
    _courierController.dispose();
    _resiController.dispose();
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
                color: (widget.sale.paymentStatus == SaleModel.statusCod ? Colors.orange : Colors.red).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: (widget.sale.paymentStatus == SaleModel.statusCod ? Colors.orange : Colors.red).withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: widget.sale.paymentStatus == SaleModel.statusCod ? Colors.orange : Colors.red,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.sale.paymentStatus == SaleModel.statusCod ? 'Bukti Pencairan Ekspedisi Belum Ada' : 'Bukti Pembayaran Belum Ada',
                    style: TextStyle(
                      color: widget.sale.paymentStatus == SaleModel.statusCod ? Colors.orange : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    widget.sale.paymentStatus == SaleModel.statusCod ? 'Wajib upload bukti pencairan dana ekspedisi sebelum set ke COMPLETE.' : 'Wajib upload bukti sebelum update ke DP/LUNAS.',
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
          const Divider(height: 24),
          const Text(
            'Status Pengiriman (Admin)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedShippingStatus,
            decoration: const InputDecoration(
              labelText: 'Pilih Status Pengiriman',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              labelStyle: TextStyle(fontSize: 12),
            ),
            style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color),
            dropdownColor: Theme.of(context).cardColor,
            items: const [
              DropdownMenuItem(value: null, child: Text('Belum Diproses')),
              DropdownMenuItem(value: 'DISIAPKAN', child: Text('Disiapkan')),
              DropdownMenuItem(value: 'DIKIRIM', child: Text('Dikirim')),
              DropdownMenuItem(value: 'SAMPAI', child: Text('Sampai')),
              DropdownMenuItem(value: 'SELESAI', child: Text('Selesai')),
            ],
            onChanged: (val) {
              setState(() {
                _selectedShippingStatus = val;
              });
            },
          ),
          if (_selectedShippingStatus == 'DIKIRIM') ...[
            const SizedBox(height: 10),
            TextField(
              controller: _courierController,
              decoration: const InputDecoration(
                labelText: 'Nama Ekspedisi (Kurir)',
                hintText: 'JNE, J&T, Sicepat, POS, dll.',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                labelStyle: TextStyle(fontSize: 12),
                hintStyle: TextStyle(fontSize: 12),
              ),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _resiController,
              decoration: const InputDecoration(
                labelText: 'Nomor Resi',
                hintText: 'Masukkan nomor resi pengiriman...',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                labelStyle: TextStyle(fontSize: 12),
                hintStyle: TextStyle(fontSize: 12),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ],
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () async {
              if (_selectedShippingStatus == 'DIKIRIM') {
                if (_courierController.text.trim().isEmpty || _resiController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kurir & Resi wajib diisi jika status Dikirim!')),
                  );
                  return;
                }
              }
              try {
                final salesService = Provider.of<SalesService>(context, listen: false);
                await salesService.updateShippingStatus(
                  widget.sale.id,
                  _selectedShippingStatus ?? 'PENDING',
                  resi: _selectedShippingStatus == 'DIKIRIM' ? _resiController.text.trim() : null,
                  courier: _selectedShippingStatus == 'DIKIRIM' ? _courierController.text.trim() : null,
                  note: _selectedShippingStatus == 'DIKIRIM'
                      ? 'Barang dikirim via ${_courierController.text.trim()} (Resi: ${_resiController.text.trim()})'
                      : 'Status barang: ${_selectedShippingStatus ?? "PENDING"}',
                  actor: 'Admin',
                );

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Status pengiriman berhasil diperbarui!')),
                );
                Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            icon: const Icon(Icons.local_shipping_rounded, size: 16),
            label: const Text('Simpan Status Pengiriman', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 36),
            ),
          ),
          const SizedBox(height: 8),
          if (widget.sale.paymentStatus == SaleModel.statusPending) ...[
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
            const Divider(height: 8),
            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: EdgeInsets.zero,
              title: const Text('Tandai sebagai COD', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: const Text('Persetujuan pesanan COD (Bayar di Tempat). Tidak butuh bukti di awal.', style: TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.delivery_dining, color: Colors.blue, size: 20),
              onTap: () {
                Navigator.pop(context);
                _updateStatus(
                  widget.sale,
                  SaleModel.statusCod,
                  note: _noteController.text,
                );
              },
            ),
          ],
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
          if (widget.sale.paymentStatus == SaleModel.statusLunas ||
              widget.sale.paymentStatus == SaleModel.statusCod) ...[
            const Divider(height: 8),
            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: EdgeInsets.zero,
              title: const Text('Tandai SELESAI (COMPLETE)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: Text(
                widget.sale.paymentStatus == SaleModel.statusCod
                    ? 'Konfirmasi uang COD telah disetor/masuk rekening penerbit.'
                    : 'Pesanan diterima/selesai.',
                style: const TextStyle(fontSize: 11),
              ),
              trailing: const Icon(Icons.done_all, color: Colors.purple, size: 20),
              onTap: () {
                if (widget.sale.paymentStatus == SaleModel.statusCod && !_hasProof) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Upload bukti pencairan dana ekspedisi dulu!')),
                  );
                  return;
                }
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
