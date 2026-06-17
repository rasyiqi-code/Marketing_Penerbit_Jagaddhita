import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/notification_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/sales_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/notification_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/storage_service.dart';
import 'package:provider/provider.dart';
import 'proof_upload_section.dart';
import 'shipping_status_section.dart';
import 'payment_actions_section.dart';

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
      final notificationService = Provider.of<FirestoreNotificationService>(context, listen: false);

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
          ProofUploadSection(
            sale: widget.sale,
            currentProofUrl: _currentProofUrl,
            hasProof: _hasProof,
            onUpload: () async {
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
          ),
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
          ShippingStatusSection(
            sale: widget.sale,
            selectedShippingStatus: _selectedShippingStatus,
            courierController: _courierController,
            resiController: _resiController,
            onStatusChanged: (val) {
              setState(() {
                _selectedShippingStatus = val;
              });
            },
            onSave: () async {
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
          ),
          const Divider(height: 8),
          PaymentActionsSection(
            sale: widget.sale,
            hasProof: _hasProof,
            noteController: _noteController,
            onUploadProofPrompt: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Upload bukti pencairan dana ekspedisi dulu!')),
              );
            },
            onUpdateStatus: (status) {
              if (status == SaleModel.statusProblem && _noteController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Wajib isi catatan masalahnya ya')),
                );
                return;
              }
              Navigator.pop(context);
              _updateStatus(widget.sale, status, note: _noteController.text);
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
