import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_formatters.dart';

/// Warning banner shown when today is not an allowed withdrawal day.
class WithdrawalAllowedDayWarning extends StatelessWidget {
  final bool isAllowedDay;
  final String dayName;

  const WithdrawalAllowedDayWarning({
    super.key,
    required this.isAllowedDay,
    required this.dayName,
  });

  @override
  Widget build(BuildContext context) {
    if (isAllowedDay) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Penarikan tidak tersedia hari ini ($dayName). Silakan cek jadwal operasional.',
              style: GoogleFonts.outfit(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.red[300]
                    : Colors.red[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient card showing the current user balance available for withdrawal.
class WithdrawalBalanceCard extends StatelessWidget {
  final bool isBank;
  final num balance;

  const WithdrawalBalanceCard({
    super.key,
    required this.isBank,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isBank
              ? [Colors.blue.shade700, Colors.blue.shade500]
              : [Colors.orange.shade700, Colors.orange.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: (isBank ? Colors.blue : Colors.orange).withValues(alpha: 0.2),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Saldo Tersedia',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            AppFormatters.currency(balance),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// The main form including the nominal, read-only info field, and submission button.
class WithdrawalForm extends StatelessWidget {
  final bool isBank;
  final bool isAllowedDay;
  final bool isLoading;
  final num minWithdrawalAmount;
  final num availableBalance;
  final TextEditingController amountController;
  final TextEditingController infoController;
  final VoidCallback onTarikSemua;
  final VoidCallback onSubmit;

  const WithdrawalForm({
    super.key,
    required this.isBank,
    required this.isAllowedDay,
    required this.isLoading,
    required this.minWithdrawalAmount,
    required this.availableBalance,
    required this.amountController,
    required this.infoController,
    required this.onTarikSemua,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isBank
              ? 'Dana akan ditransfer ke rekening bank Anda.'
              : 'Pulsa akan dikirim ke nomor HP Anda.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 13,
          ),
        ),
        if (minWithdrawalAmount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
            child: Text(
              'Minimal penarikan: ${AppFormatters.currency(minWithdrawalAmount)}',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: isDark ? Colors.red[300] : Colors.red[700],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(height: 10),

        // Nominal Input Field
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          enabled: isAllowedDay,
          style: GoogleFonts.outfit(),
          decoration: InputDecoration(
            labelText: 'Nominal Penarikan',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            prefixText: 'Rp ',
            suffixIcon: TextButton(
              onPressed: isAllowedDay ? onTarikSemua : null,
              child: const Text('Tarik Semua'),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Banking/Phone Info (Read-only) Field
        TextField(
          controller: infoController,
          readOnly: true,
          enabled: isAllowedDay,
          style: GoogleFonts.outfit(),
          decoration: InputDecoration(
            labelText: isBank ? 'Bank & No. Rekening' : 'Nomor HP',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            hintText: 'Belum diset',
            filled: true,
            fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            helperText: infoController.text.isNotEmpty
                ? 'Data dikunci. Ubah via Profile.'
                : 'Mohon lengkapi data di menu Profile.',
            helperStyle: TextStyle(
              color: infoController.text.isEmpty ? Colors.red : (isDark ? Colors.grey[400] : Colors.grey[600]),
              fontSize: 11,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.edit_rounded, size: 18),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Silakan ubah data di menu Profile'),
                  ),
                );
              },
              tooltip: 'Ubah di Profile',
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Submission Button
        SizedBox(
          height: 40,
          child: ElevatedButton(
            onPressed: (isLoading || infoController.text.isEmpty || !isAllowedDay)
                ? null
                : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              disabledBackgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Kirim Permintaan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
