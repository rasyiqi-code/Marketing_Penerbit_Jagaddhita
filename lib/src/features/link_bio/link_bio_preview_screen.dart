import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/link_bio_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/poster_export_helper.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/link_bio/widgets/digital_business_card.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/link_bio/widgets/link_bio_book_catalog_section.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/link_bio/widgets/link_bio_profile_header.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/link_bio/widgets/link_bio_shared_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkBioPreviewScreen extends StatefulWidget {
  final UserModel user;
  final List<LinkBioModel> links;
  final bool isPublicView;

  const LinkBioPreviewScreen({
    super.key,
    required this.user,
    required this.links,
    this.isPublicView = false,
  });

  @override
  State<LinkBioPreviewScreen> createState() => _LinkBioPreviewScreenState();
}

class _LinkBioPreviewScreenState extends State<LinkBioPreviewScreen> {
  final GlobalKey _cardKey = GlobalKey();

  List<LinkBioModel> get _contentLinks =>
      widget.links.where((l) => l.isActive).toList();

  // ── URL / WA Helpers ────────────────────────────────────────────────────────

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  void _sendWhatsAppMessage(String? number, String message) {
    if (number == null || number.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marketing belum mengonfigurasi nomor WhatsApp.'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }
    String cleaned = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (!cleaned.startsWith('62') && cleaned.startsWith('0')) {
      cleaned = '62${cleaned.substring(1)}';
    }
    final encodedMsg = Uri.encodeComponent(message);
    _launchUrl('https://wa.me/$cleaned?text=$encodedMsg');
  }

  // ── Business Card ───────────────────────────────────────────────────────────

  Future<void> _downloadBusinessCard(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      await Future.delayed(const Duration(milliseconds: 300));

      final boundary = _cardKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Gagal mendeteksi area kartu.');

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ImageByteFormat.png);
      if (byteData == null) throw Exception('Gagal mengonversi gambar.');

      final bytes = byteData.buffer.asUint8List();
      final fileName = 'kartu_nama_${widget.user.name ?? "mitra"}.png';

      if (context.mounted) Navigator.pop(context);
      await PosterExportHelper.exportImage(bytes, fileName);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kartu Nama berhasil disimpan/dibagikan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan kartu nama: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showBusinessCardDialog(
      String displayName, String professionalTitle) {
    showDigitalBusinessCardDialog(
      context: context,
      user: widget.user,
      displayName: displayName,
      professionalTitle: professionalTitle,
      cardKey: _cardKey,
      onDownload: _downloadBusinessCard,
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final displayName =
        widget.user.name ?? widget.user.email.split('@')[0];
    final professionalTitle = widget.user.marketingCategory != null
        ? '${widget.user.marketingCategory![0].toUpperCase()}'
            '${widget.user.marketingCategory!.substring(1)} Kemitraan'
        : 'Mitra Penerbit Jagaddhita';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const LinkBioBackgroundDecoration(),
          SafeArea(
            child: Column(
              children: [
                // Nav close button (preview mode only)
                if (!widget.isPublicView)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        LinkBioGlassIconButton(
                          icon: Icons.close,
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // ── Profile Header ──────────────────────────
                        LinkBioProfileHeader(
                          user: widget.user,
                          displayName: displayName,
                          professionalTitle: professionalTitle,
                          onSendWhatsApp: _sendWhatsAppMessage,
                          onShowBusinessCard: () =>
                              _showBusinessCardDialog(
                                  displayName, professionalTitle),
                        ),

                        const SizedBox(height: 16),

                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              // ── Book Catalog ──────────────────────
                              if (widget.user.showJagaddhitaCatalog ||
                                  widget.user.showSibiCatalog) ...[
                                LinkBioBookCatalogSection(
                                  user: widget.user,
                                  onSendWhatsApp: _sendWhatsAppMessage,
                                ),
                                const SizedBox(height: 20),
                              ],

                              // ── Custom Links ──────────────────────
                              if (_contentLinks.isNotEmpty) ...[
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 10.0),
                                    child: Text(
                                      'Tautan Lainnya',
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                                ..._contentLinks.map(
                                  (link) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12),
                                    child: LinkBioModernLinkButton(
                                      link: link,
                                      onTap: () => _launchUrl(link.url),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],

                              // ── Branding Footer ───────────────────
                              _BrandingFooter(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
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

class _BrandingFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.bolt_rounded,
            color: Colors.white,
            size: 12,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Powered by Jagaddhita App',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
