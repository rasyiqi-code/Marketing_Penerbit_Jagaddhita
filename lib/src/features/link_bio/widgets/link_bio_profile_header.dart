import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/network_image_web_helper.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/link_bio/widgets/link_bio_shared_widgets.dart';

/// Profile header section of the link bio preview page.
/// Displays avatar, name, title, social buttons, and business card trigger.
class LinkBioProfileHeader extends StatelessWidget {
  final UserModel user;
  final String displayName;
  final String professionalTitle;

  /// Called when user taps a social/WA button.
  /// [number] may be null (not configured). [message] is the pre-filled WA text.
  final void Function(String? number, String message) onSendWhatsApp;

  /// Called when user taps the digital business card button.
  final VoidCallback onShowBusinessCard;

  const LinkBioProfileHeader({
    super.key,
    required this.user,
    required this.displayName,
    required this.professionalTitle,
    required this.onSendWhatsApp,
    required this.onShowBusinessCard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
        ),
      ),
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: 10),
          _buildNameRow(),
          const SizedBox(height: 2),
          Text(
            professionalTitle,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildSocialRow(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF6A11CB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: ClipOval(
          child: user.photoUrl != null
              ? NetworkImageWeb(
                  imageUrl: user.photoUrl!,
                  fit: BoxFit.cover,
                  errorWidget: _avatarFallback(),
                )
              : _avatarFallback(),
        ),
      ),
    );
  }

  Widget _avatarFallback() {
    return Center(
      child: Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
        style: GoogleFonts.outfit(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildNameRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            displayName,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.verified, color: Colors.blue, size: 18),
      ],
    );
  }

  Widget _buildSocialRow() {
    final hasWa =
        user.whatsappNumber != null && user.whatsappNumber!.isNotEmpty;
    final hasIg = user.instagramUrl != null && user.instagramUrl!.isNotEmpty;
    final hasTt = user.tiktokUrl != null && user.tiktokUrl!.isNotEmpty;
    final hasFb = user.facebookUrl != null && user.facebookUrl!.isNotEmpty;

    if (!hasWa && !hasIg && !hasTt && !hasFb) {
      return Text(
        'Kontak kami via link di bawah',
        style: GoogleFonts.outfit(
          fontSize: 11,
          color: Colors.grey[400],
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasWa)
          LinkBioSocialCircleButton(
            icon: Icons.chat_bubble,
            color: const Color(0xFF25D366),
            onTap: () => onSendWhatsApp(
              user.whatsappNumber,
              'Halo Kak, saya tertarik bertanya mengenai buku.',
            ),
          ),
        if (hasIg) ...[
          const SizedBox(width: 12),
          LinkBioSocialCircleButton(
            icon: Icons.camera_alt,
            color: const Color(0xFFE1306C),
            onTap: () {},
          ),
        ],
        if (hasTt) ...[
          const SizedBox(width: 12),
          LinkBioSocialCircleButton(
            icon: Icons.music_note_rounded,
            color: Colors.black,
            onTap: () {},
          ),
        ],
        if (hasFb) ...[
          const SizedBox(width: 12),
          LinkBioSocialCircleButton(
            icon: Icons.facebook,
            color: const Color(0xFF1877F2),
            onTap: () {},
          ),
        ],
        // Business card button — compact circle, same size as social icons
        const SizedBox(width: 12),
        Tooltip(
          message: 'Kartu Nama Digital',
          child: InkWell(
            onTap: onShowBusinessCard,
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.25),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.badge_outlined,
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
