import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';

/// A premium visual Digital Business Card widget representation
class DigitalBusinessCard extends StatelessWidget {
  final UserModel user;
  final String displayName;
  final String professionalTitle;

  const DigitalBusinessCard({
    super.key,
    required this.user,
    required this.displayName,
    required this.professionalTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 450,
      height: 275,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1B5E20), // Dark forest green
            Color(0xFF008A45), // Jagaddhita green
            Color(0xFF388E3C), // Lighter green
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Red Brand Accent
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withValues(alpha: 0.9), // Crimson Red Accent
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(120),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          // Elegant wave shapes
          Positioned(
            right: -30,
            bottom: -30,
            child: Opacity(
              opacity: 0.1,
              child: const Icon(
                Icons.menu_book,
                size: 200,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: -50,
            top: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Inner layout
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // Left Column: User info & profile photo
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Avatar with gold border
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accentColor, // Gold border
                        ),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: ClipOval(
                            child: user.photoUrl != null
                                ? Image.network(
                                    'https://images.weserv.nl/?url=${Uri.encodeComponent(user.photoUrl!)}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Center(
                                      child: Text(
                                        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                                        style: GoogleFonts.outfit(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                                      style: GoogleFonts.outfit(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Partner Name with Verified Icon
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Title Tag with gold style
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppTheme.accentColor.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          professionalTitle.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Divider
                Container(
                  width: 1,
                  height: 180,
                  color: Colors.white24,
                ),
                const SizedBox(width: 16),
                // Right Column: Company branding & contacts
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Brand Logo/Header
                      Row(
                        children: [
                          const Icon(
                            Icons.menu_book_rounded,
                            color: AppTheme.accentColor,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Penerbit Jagaddhita',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Contact details
                      _buildContactRow(Icons.phone_iphone_rounded, user.whatsappNumber ?? '-'),
                      const SizedBox(height: 8),
                      _buildContactRow(Icons.camera_alt_outlined, user.instagramUrl != null && user.instagramUrl!.isNotEmpty ? '@${user.instagramUrl}' : '-'),
                      const SizedBox(height: 16),
                      // QR Code illustration box
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const CustomPaint(
                              painter: MockQrPainter(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Katalog Digital',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Pindai QR untuk melihat katalog saya',
                                  style: GoogleFonts.outfit(
                                    fontSize: 8,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 12,
          color: Colors.white70,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class MockQrPainter extends CustomPainter {
  const MockQrPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    // Draw finder patterns
    void drawFinderPattern(double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x, y, 12, 12), paint);
      final whitePaint = Paint()..color = Colors.white;
      canvas.drawRect(Rect.fromLTWH(x + 2, y + 2, 8, 8), whitePaint);
      canvas.drawRect(Rect.fromLTWH(x + 4, y + 4, 4, 4), paint);
    }

    drawFinderPattern(0, 0);
    drawFinderPattern(size.width - 12, 0);
    drawFinderPattern(0, size.height - 12);

    // Mock QR blocks
    canvas.drawRect(Rect.fromLTWH(16, 2, 4, 4), paint);
    canvas.drawRect(Rect.fromLTWH(20, 6, 4, 4), paint);
    canvas.drawRect(Rect.fromLTWH(16, 16, 8, 4), paint);
    canvas.drawRect(Rect.fromLTWH(4, 16, 4, 8), paint);
    canvas.drawRect(Rect.fromLTWH(16, 24, 4, 4), paint);
    canvas.drawRect(Rect.fromLTWH(24, 16, 4, 4), paint);
    canvas.drawRect(Rect.fromLTWH(28, 20, 4, 4), paint);
    canvas.drawRect(Rect.fromLTWH(20, 28, 8, 4), paint);
    canvas.drawRect(Rect.fromLTWH(28, 28, 4, 4), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Helper function to show the digital business card dialog beautifully
void showDigitalBusinessCardDialog({
  required BuildContext context,
  required UserModel user,
  required String displayName,
  required String professionalTitle,
  required GlobalKey cardKey,
  required Future<void> Function(BuildContext) onDownload,
}) {
  showDialog(
    context: context,
    builder: (dialogCtx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.contain,
              child: RepaintBoundary(
                key: cardKey,
                child: DigitalBusinessCard(
                  user: user,
                  displayName: displayName,
                  professionalTitle: professionalTitle,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await onDownload(context);
                    if (dialogCtx.mounted) {
                      Navigator.pop(dialogCtx);
                    }
                  },
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: Text(
                    'Unduh Kartu Nama',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.white54),
                    ),
                  ),
                  child: Text(
                    'Tutup',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
