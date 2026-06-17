import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'social_media_text_field.dart';

class LinkBioSocialForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final bool showJagaddhita;
  final bool showSibi;
  final bool isSavingSocial;
  final TextEditingController whatsappController;
  final TextEditingController instagramController;
  final TextEditingController tiktokController;
  final TextEditingController facebookController;
  final ValueChanged<bool> onShowJagaddhitaChanged;
  final ValueChanged<bool> onShowSibiChanged;
  final VoidCallback onSave;

  const LinkBioSocialForm({
    super.key,
    required this.formKey,
    required this.showJagaddhita,
    required this.showSibi,
    required this.isSavingSocial,
    required this.whatsappController,
    required this.instagramController,
    required this.tiktokController,
    required this.facebookController,
    required this.onShowJagaddhitaChanged,
    required this.onShowSibiChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.contact_mail_rounded,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 10),
              Text(
                'Kartu Nama & Katalog Digital',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.15 : 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.3 : 0.15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.badge,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kartu Nama Digital Premium Anda Siap!',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Buka menu "Pratinjau" di atas untuk melihat dan mengunduh Kartu Nama Digital eksklusif Anda sebagai gambar berkualitas tinggi.',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: isDark ? Colors.grey[300] : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Katalog Jagaddhita Media Pustaka',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              'Menampilkan buku anak & PAUD berkualitas',
              style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            value: showJagaddhita,
            onChanged: onShowJagaddhitaChanged,
            activeThumbColor: AppTheme.primaryColor,
          ),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Katalog SIBI Kemendikbudristek',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              'Menampilkan buku teks kurikulum nasional SIBI',
              style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            value: showSibi,
            onChanged: onShowSibiChanged,
            activeThumbColor: AppTheme.primaryColor,
          ),
          const Divider(height: 12),
          Text(
            'Kontak & Media Sosial Mitra',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 6),
          SocialMediaTextField(
            controller: whatsappController,
            label: 'Nomor WhatsApp (Contoh: 628123456789)',
            icon: Icons.chat_rounded,
            iconColor: Colors.green,
            keyboardType: TextInputType.phone,
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          SocialMediaTextField(
            controller: instagramController,
            label: 'Username Instagram (Tanpa @)',
            icon: Icons.camera_alt,
            iconColor: Colors.pink,
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          SocialMediaTextField(
            controller: tiktokController,
            label: 'Username TikTok (Tanpa @)',
            icon: Icons.music_note,
            iconColor: isDark ? Colors.white : Colors.black,
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          SocialMediaTextField(
            controller: facebookController,
            label: 'Username / Profil Facebook',
            icon: Icons.facebook,
            iconColor: Colors.blue,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: isSavingSocial ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isSavingSocial
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Simpan Profil & Katalog',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
