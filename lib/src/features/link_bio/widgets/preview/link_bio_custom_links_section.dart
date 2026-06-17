import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/link_bio_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/link_bio/widgets/admin/link_bio_admin_widgets.dart';

/// Bagian form media sosial dan daftar link kustom pada halaman Link Bio.
class LinkBioCustomLinksSection extends StatelessWidget {
  final GlobalKey<FormState> socialFormKey;
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
  final List<LinkBioModel> links;
  final VoidCallback onAddLink;
  final ValueChanged<LinkBioModel> onToggleActive;
  final ValueChanged<LinkBioModel> onEdit;
  final ValueChanged<LinkBioModel> onDelete;

  const LinkBioCustomLinksSection({
    super.key,
    required this.socialFormKey,
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
    required this.links,
    required this.onAddLink,
    required this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          )
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: isDark ? 0.05 : 0.1),
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Social & Catalogs Form ──────────────────────────────
          LinkBioSocialForm(
            formKey: socialFormKey,
            showJagaddhita: showJagaddhita,
            showSibi: showSibi,
            isSavingSocial: isSavingSocial,
            whatsappController: whatsappController,
            instagramController: instagramController,
            tiktokController: tiktokController,
            facebookController: facebookController,
            onShowJagaddhitaChanged: onShowJagaddhitaChanged,
            onShowSibiChanged: onShowSibiChanged,
            onSave: onSave,
          ),

          const SizedBox(height: 12),

          // ── Custom Links Header ─────────────────────────────────
          if (links.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Link Custom',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),

          // ── Custom Links List ───────────────────────────────────
          ...links.map(
            (link) => LinkBioCustomLinkCard(
              link: link,
              onToggleActive: (val) => onToggleActive(link),
              onEdit: () => onEdit(link),
              onDelete: () => onDelete(link),
            ),
          ),

          // ── Add New Link Button ─────────────────────────────────
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton.icon(
              onPressed: onAddLink,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                side: BorderSide(
                  color: AppTheme.primaryColor.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.05),
              ),
              icon: const Icon(Icons.add_circle_outline, size: 16),
              label: Text(
                'Tambah Link Custom Baru',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),

          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
