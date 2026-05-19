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
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
        ),
      ),
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: 16),
          _buildNameRow(),
          const SizedBox(height: 4),
          Text(
            professionalTitle,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          _buildSocialRow(),
          const SizedBox(height: 16),
          _buildBusinessCardButton(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      padding: const EdgeInsets.all(4),
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
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        width: 92,
        height: 92,
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
          fontSize: 36,
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
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.verified, color: Colors.blue, size: 24),
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
          fontSize: 12,
          color: Colors.grey[400],
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
      ],
    );
  }

  Widget _buildBusinessCardButton() {
    return ElevatedButton.icon(
      onPressed: onShowBusinessCard,
      icon: const Icon(Icons.badge_outlined, size: 16),
      label: Text(
        'Kartu Nama Digital',
        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: const Size(0, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
        ),
      ),
    );
  }
}
