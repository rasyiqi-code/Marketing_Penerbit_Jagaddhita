import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/link_bio_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/link_bio/link_bio_preview_screen.dart';

/// Top header card displaying public bio URL, active count, copy button, and preview option.
class LinkBioHeaderCard extends StatelessWidget {
  final UserModel user;
  final List<LinkBioModel> links;
  final String webBaseUrl;

  const LinkBioHeaderCard({
    super.key,
    required this.user,
    required this.links,
    required this.webBaseUrl,
  });

  @override
  Widget build(BuildContext context) {
    String baseUrl = webBaseUrl;
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    final identifier = user.username != null && user.username!.isNotEmpty
        ? user.username
        : user.id;
    final bioUrl = '$baseUrl/bio/$identifier';
    final activeCount = links.where((l) => l.isActive).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.public, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Public Bio Anda',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$activeCount Link Aktif',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      // ignore: deprecated_member_use
                      await Share.share(
                        'Check out my bio: $bioUrl',
                        subject: 'My Jagaddhita Bio',
                      );
                    },
                    icon: const Icon(
                      Icons.share,
                      color: Colors.white,
                    ),
                    tooltip: 'Bagikan Bio',
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      shape: const StadiumBorder(),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      minimumSize: const Size(0, 36),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LinkBioPreviewScreen(
                            user: user,
                            links: links,
                          ),
                        ),
                      );
                    },
                    child: const Text('Pratinjau'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Copy Link Box
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    bioUrl,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(text: bioUrl),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Link berhasil disalin!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.copy,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Form for custom settings: digital business card settings, catalog selectors, and social links.
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.badge,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kartu Nama Digital Premium Anda Siap!',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Buka menu "Pratinjau" di atas untuk melihat dan mengunduh Kartu Nama Digital eksklusif Anda sebagai gambar berkualitas tinggi.',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Catalog Toggles
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Katalog Jagaddhita Media Pustaka',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Menampilkan buku anak & PAUD berkualitas',
              style: TextStyle(fontSize: 12),
            ),
            value: showJagaddhita,
            onChanged: onShowJagaddhitaChanged,
            activeThumbColor: AppTheme.primaryColor,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Katalog SIBI Kemendikbudristek',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Menampilkan buku teks kurikulum nasional SIBI',
              style: TextStyle(fontSize: 12),
            ),
            value: showSibi,
            onChanged: onShowSibiChanged,
            activeThumbColor: AppTheme.primaryColor,
          ),
          const Divider(height: 24),
          Text(
            'Kontak & Media Sosial Mitra',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          // Social Media Inputs
          TextFormField(
            controller: whatsappController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Nomor WhatsApp (Contoh: 628123456789)',
              prefixIcon: const Icon(Icons.chat_rounded, color: Colors.green),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: instagramController,
            decoration: InputDecoration(
              labelText: 'Username Instagram (Tanpa @)',
              prefixIcon: const Icon(Icons.camera_alt, color: Colors.pink),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: tiktokController,
            decoration: InputDecoration(
              labelText: 'Username TikTok (Tanpa @)',
              prefixIcon: const Icon(Icons.music_note, color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: facebookController,
            decoration: InputDecoration(
              labelText: 'Username / Profil Facebook',
              prefixIcon: const Icon(Icons.facebook, color: Colors.blue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isSavingSocial ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isSavingSocial
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Simpan Profil & Katalog',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Custom link list card showing label, URL, status toggle, and edit/delete actions.
class LinkBioCustomLinkCard extends StatelessWidget {
  final LinkBioModel link;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LinkBioCustomLinkCard({
    super.key,
    required this.link,
    required this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (link.icon) {
      case 'instagram':
        icon = Icons.camera_alt_outlined;
        break;
      case 'whatsapp':
        icon = Icons.chat_bubble_outline;
        break;
      case 'facebook':
        icon = Icons.facebook;
        break;
      case 'twitter':
        icon = Icons.alternate_email;
        break;
      case 'store':
        icon = Icons.storefront;
        break;
      case 'book':
        icon = Icons.book_outlined;
        break;
      default:
        icon = Icons.language;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(
          link.label,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          link.url,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: link.isActive,
              activeThumbColor: AppTheme.primaryColor,
              onChanged: onToggleActive,
            ),
            PopupMenuButton(
              icon: Icon(Icons.more_vert, color: Colors.grey[600]),
              onSelected: (val) {
                if (val == 'edit') onEdit();
                if (val == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Hapus', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
