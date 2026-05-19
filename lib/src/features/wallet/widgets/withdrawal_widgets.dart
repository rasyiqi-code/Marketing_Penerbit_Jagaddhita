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
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Penarikan tidak tersedia hari ini ($dayName). Silakan cek jadwal operasional.',
              style: GoogleFonts.outfit(
                color: Colors.red[800],
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isBank
              ? [Colors.blue.shade700, Colors.blue.shade500]
              : [Colors.orange.shade700, Colors.orange.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isBank ? Colors.blue : Colors.orange).withValues(alpha: 0.3),
            offset: const Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Saldo Tersedia',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppFormatters.currency(balance),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 32,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isBank
              ? 'Dana akan ditransfer ke rekening bank Anda.'
              : 'Pulsa akan dikirim ke nomor HP Anda.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),
        if (minWithdrawalAmount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              'Minimal penarikan: ${AppFormatters.currency(minWithdrawalAmount)}',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.red[700],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(height: 24),

        // Nominal Input Field
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          enabled: isAllowedDay,
          decoration: InputDecoration(
            labelText: 'Nominal Penarikan',
            border: const OutlineInputBorder(),
            prefixText: 'Rp ',
            suffixIcon: TextButton(
              onPressed: isAllowedDay ? onTarikSemua : null,
              child: const Text('Tarik Semua'),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Banking/Phone Info (Read-only) Field
        TextField(
          controller: infoController,
          readOnly: true,
          enabled: isAllowedDay,
          decoration: InputDecoration(
            labelText: isBank ? 'Bank & No. Rekening' : 'Nomor HP',
            border: const OutlineInputBorder(),
            hintText: 'Belum diset',
            filled: true,
            fillColor: Colors.grey[100],
            helperText: infoController.text.isNotEmpty
                ? 'Data dikunci. Ubah via Profile.'
                : 'Mohon lengkapi data di menu Profile.',
            helperStyle: TextStyle(
              color: infoController.text.isEmpty ? Colors.red : null,
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

        const SizedBox(height: 32),

        // Submission Button
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: (isLoading || infoController.text.isEmpty || !isAllowedDay)
                ? null
                : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              disabledBackgroundColor: Colors.grey[300],
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
