import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';

class ShippingStatusSection extends StatelessWidget {
  final SaleModel sale;
  final String? selectedShippingStatus;
  final TextEditingController courierController;
  final TextEditingController resiController;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onSave;

  const ShippingStatusSection({
    super.key,
    required this.sale,
    required this.selectedShippingStatus,
    required this.courierController,
    required this.resiController,
    required this.onStatusChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Status Pengiriman (Admin)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedShippingStatus,
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
          onChanged: onStatusChanged,
        ),
        if (selectedShippingStatus == 'DIKIRIM') ...[
          const SizedBox(height: 10),
          TextField(
            controller: courierController,
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
            controller: resiController,
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
          onPressed: onSave,
          icon: const Icon(Icons.local_shipping_rounded, size: 16),
          label: const Text('Simpan Status Pengiriman', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
