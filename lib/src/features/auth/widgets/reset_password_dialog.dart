import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/auth_service.dart';
import 'package:provider/provider.dart';

/// Menampilkan dialog reset password untuk email yang diberikan.
void showResetPasswordDialog(BuildContext context, String email) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: const Text(
        'Reset Password',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      content: Text(
        'Send password reset email to $email?',
        style: const TextStyle(fontSize: 13),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel', style: TextStyle(fontSize: 13)),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(ctx);
            try {
              await Provider.of<AuthService>(context, listen: false)
                  .resetPassword(email);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reset email sent! Check your inbox.'),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Send', style: TextStyle(fontSize: 13)),
        ),
      ],
    ),
  );
}
