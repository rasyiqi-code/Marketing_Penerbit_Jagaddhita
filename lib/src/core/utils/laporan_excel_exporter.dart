import 'package:flutter/foundation.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/sale_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/excel_export_helper.dart';

class LaporanExcelExporter {
  static Future<void> exportSalesToExcel(
    List<SaleModel> sales, {
    required String fileName,
    bool isAdmin = false,
  }) async {
    try {
      final excel = Excel.createExcel();
      // Remove default sheet if necessary or just overwrite it
      final sheetName = excel.getDefaultSheet() ?? 'Laporan Penjualan';
      final sheet = excel[sheetName];

      // Define standard headers
      final headers = isAdmin
          ? [
              TextCellValue('No'),
              TextCellValue('Tanggal'),
              TextCellValue('ID Transaksi'),
              TextCellValue('Nama Agen'),
              TextCellValue('Customer'),
              TextCellValue('No. HP Customer'),
              TextCellValue('Daftar Buku'),
              TextCellValue('Total Qty (Eks)'),
              TextCellValue('Total Harga (Bruto)'),
              TextCellValue('Komisi Agen'),
              TextCellValue('Keuntungan Markup'),
              TextCellValue('Status'),
            ]
          : [
              TextCellValue('No'),
              TextCellValue('Tanggal'),
              TextCellValue('ID Transaksi'),
              TextCellValue('Customer'),
              TextCellValue('No. HP Customer'),
              TextCellValue('Daftar Buku'),
              TextCellValue('Total Qty (Eks)'),
              TextCellValue('Total Harga (Bruto)'),
              TextCellValue('Komisi Agen'),
              TextCellValue('Keuntungan Markup'),
              TextCellValue('Jumlah Bayar'),
              TextCellValue('Sisa Tagihan'),
              TextCellValue('Status'),
            ];

      // Append header row
      sheet.appendRow(headers);

      // Apply cell styling to header row
      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
        cell.cellStyle = CellStyle(
          bold: true,
          fontFamily: getFontFamily(FontFamily.Calibri),
          backgroundColorHex: ExcelColor.fromHexString('#008A45'), // Publisher primary green
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
          horizontalAlign: HorizontalAlign.Center,
        );
      }

      // Populate data rows
      for (int i = 0; i < sales.length; i++) {
        final sale = sales[i];
        final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(sale.createdAt);

        // Build itemized book details string (e.g. "Buku A (x2), Buku B (x5)")
        final productSummaryList = <String>[];
        final names = sale.productNames;
        final quantities = sale.productQuantities;
        for (int idx = 0; idx < names.length; idx++) {
          final q = quantities.length > idx ? quantities[idx] : 1;
          productSummaryList.add('${names[idx]} (x$q)');
        }
        final booksString = productSummaryList.join(', ');
        final totalQty = quantities.fold<int>(0, (sum, q) => sum + q);

        final List<CellValue> rowData = isAdmin
            ? [
                IntCellValue(i + 1),
                TextCellValue(dateStr),
                TextCellValue(sale.id.toUpperCase()),
                TextCellValue(sale.details['agent_name'] ?? 'Unknown'),
                TextCellValue(sale.customerName),
                TextCellValue(sale.customerPhone),
                TextCellValue(booksString),
                IntCellValue(totalQty),
                DoubleCellValue(sale.totalPrice),
                DoubleCellValue(sale.commissionAmount),
                DoubleCellValue((sale.totalMarkup ?? 0).toDouble()),
                TextCellValue(sale.paymentStatus),
              ]
            : [
                IntCellValue(i + 1),
                TextCellValue(dateStr),
                TextCellValue(sale.id.toUpperCase()),
                TextCellValue(sale.customerName),
                TextCellValue(sale.customerPhone),
                TextCellValue(booksString),
                IntCellValue(totalQty),
                DoubleCellValue(sale.totalPrice),
                DoubleCellValue(sale.commissionAmount),
                DoubleCellValue((sale.totalMarkup ?? 0).toDouble()),
                DoubleCellValue(sale.paidAmount),
                DoubleCellValue(sale.totalPrice - sale.paidAmount),
                TextCellValue(sale.paymentStatus),
              ];

        sheet.appendRow(rowData);

        // Apply grid/body borders and styles
        for (int col = 0; col < rowData.length; col++) {
          final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: i + 1));
          cell.cellStyle = CellStyle(
            fontFamily: getFontFamily(FontFamily.Calibri),
            horizontalAlign: (col == 0 || col == 1 || col == 7 || col == rowData.length - 1)
                ? HorizontalAlign.Center
                : HorizontalAlign.Left,
          );
        }
      }

      // Convert sheet data to binary Excel file bytes
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final bytes = Uint8List.fromList(fileBytes);
        await ExcelExportHelper.exportExcel(bytes, fileName);
      }
    } catch (e) {
      debugPrint('Error writing sales report to Excel: $e');
      rethrow;
    }
  }
}
