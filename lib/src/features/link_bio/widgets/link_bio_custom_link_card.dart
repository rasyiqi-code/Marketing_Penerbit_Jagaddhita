import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/link_bio_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isDark ? 0 : 2,
      color: Theme.of(context).cardColor,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: isDark ? 0.05 : 0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 18),
        ),
        title: Text(
          link.label,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          link.url,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 11,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: link.isActive,
              activeThumbColor: AppTheme.primaryColor,
              onChanged: onToggleActive,
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              onSelected: (val) {
                if (val == 'edit') onEdit();
                if (val == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20, color: Theme.of(context).colorScheme.onSurface),
                      const SizedBox(width: 8),
                      Text('Edit', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      const Text('Hapus', style: TextStyle(color: Colors.red)),
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
