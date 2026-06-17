import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';

class PaymentActionsSection extends StatelessWidget {
  final SaleModel sale;
  final bool hasProof;
  final TextEditingController noteController;
  final Function(String status) onUpdateStatus;
  final VoidCallback onUploadProofPrompt;

  const PaymentActionsSection({
    super.key,
    required this.sale,
    required this.hasProof,
    required this.noteController,
    required this.onUpdateStatus,
    required this.onUploadProofPrompt,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];

    // Pending payment actions
    if (sale.paymentStatus == SaleModel.statusPending) {
      final req = sale.details['requested_status'];
      if (req == 'COD') {
        children.add(
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: EdgeInsets.zero,
            title: const Text('Setujui Pembayaran COD', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: const Text('Pesanan disetujui untuk dikirim dengan metode COD.', style: TextStyle(fontSize: 11)),
            trailing: const Icon(Icons.delivery_dining, color: Colors.orange, size: 20),
            onTap: () => onUpdateStatus(SaleModel.statusCod),
          ),
        );
      } else if (req == 'DP') {
        children.add(
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: EdgeInsets.zero,
            title: const Text('Setujui Pembayaran DP', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: !hasProof
                ? const Text('Wajib bukti foto!', style: TextStyle(color: Colors.red, fontSize: 11))
                : null,
            enabled: hasProof,
            trailing: Icon(Icons.payments_outlined, color: hasProof ? Colors.blue : Colors.grey, size: 20),
            onTap: () => onUpdateStatus(SaleModel.statusDp),
          ),
        );
      } else {
        children.add(
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: EdgeInsets.zero,
            title: const Text('Setujui Pembayaran LUNAS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text(
              !hasProof
                  ? 'Wajib bukti foto!'
                  : 'Status LUNAS belum mencairkan bonus.',
              style: TextStyle(color: !hasProof ? Colors.red : Colors.grey[600], fontSize: 11),
            ),
            trailing: Icon(Icons.check_circle, color: hasProof ? Colors.green : Colors.grey, size: 20),
            enabled: hasProof,
            onTap: () => onUpdateStatus(SaleModel.statusLunas),
          ),
        );
      }
    }

    // DP payment actions (allow Lunas)
    if (sale.paymentStatus == SaleModel.statusDp) {
      if (children.isNotEmpty) children.add(const Divider(height: 8));
      children.add(
        ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          contentPadding: EdgeInsets.zero,
          title: const Text('Setujui Pelunasan (LUNAS)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          subtitle: Text(
            !hasProof
                ? 'Wajib bukti foto pelunasan!'
                : 'Status LUNAS belum mencairkan bonus.',
            style: TextStyle(
              color: !hasProof ? Colors.red : Colors.grey[600],
              fontSize: 11,
            ),
          ),
          trailing: Icon(
            Icons.check_circle,
            color: hasProof ? Colors.green : Colors.grey,
            size: 20,
          ),
          enabled: hasProof,
          onTap: () => onUpdateStatus(SaleModel.statusLunas),
        ),
      );
    }

    // Lunas or COD payment actions (allow complete)
    if (sale.paymentStatus == SaleModel.statusLunas ||
        sale.paymentStatus == SaleModel.statusCod) {
      if (children.isNotEmpty) children.add(const Divider(height: 8));
      children.add(
        ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          contentPadding: EdgeInsets.zero,
          title: const Text('Tandai SELESAI (COMPLETE)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          subtitle: Text(
            sale.paymentStatus == SaleModel.statusCod
                ? 'Konfirmasi uang COD telah disetor/masuk rekening penerbit.'
                : 'Pesanan diterima/selesai.',
            style: const TextStyle(fontSize: 11),
          ),
          trailing: const Icon(Icons.done_all, color: Colors.purple, size: 20),
          onTap: () {
            if (sale.paymentStatus == SaleModel.statusCod && !hasProof) {
              onUploadProofPrompt();
              return;
            }
            onUpdateStatus(SaleModel.statusComplete);
          },
        ),
      );
    }

    // Problem marker (always allow)
    if (children.isNotEmpty) children.add(const Divider(height: 8));
    children.add(
      ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: EdgeInsets.zero,
        title: const Text('Tandai BERMASALAH', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.red)),
        subtitle: const Text('Ada masalah pembayaran/pesanan.', style: TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.report_problem, color: Colors.red, size: 20),
        textColor: Colors.red,
        onTap: () => onUpdateStatus(SaleModel.statusProblem),
      ),
    );

    return Column(
      children: children,
    );
  }
}
