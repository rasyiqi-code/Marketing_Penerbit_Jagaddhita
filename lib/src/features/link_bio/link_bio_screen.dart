import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/global_settings_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/link_bio_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/auth_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/link_bio_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/product_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/user_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/link_bio/add_edit_link_dialog.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/link_bio/widgets/link_bio_admin_widgets.dart';

class LinkBioScreen extends StatefulWidget {
  const LinkBioScreen({super.key});

  @override
  State<LinkBioScreen> createState() => _LinkBioScreenState();
}

class _LinkBioScreenState extends State<LinkBioScreen> {
  UserModel? _currentUser;

  // Social & Catalog Preference Controllers
  final _socialFormKey = GlobalKey<FormState>();
  final _whatsappController = TextEditingController();
  final _instagramController = TextEditingController();
  final _tiktokController = TextEditingController();
  final _facebookController = TextEditingController();

  bool _showJagaddhita = true;
  bool _showSibi = true;
  bool _isSavingSocial = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final user = await auth.getCurrentUserDetails();
    if (mounted && user != null) {
      setState(() {
        _currentUser = user;
        _showJagaddhita = user.showJagaddhitaCatalog;
        _showSibi = user.showSibiCatalog;
        _whatsappController.text = user.whatsappNumber ?? '';
        _instagramController.text = user.instagramUrl ?? '';
        _tiktokController.text = user.tiktokUrl ?? '';
        _facebookController.text = user.facebookUrl ?? '';
      });
    }
  }

  void _showAddEditDialog([LinkBioModel? link]) {
    showDialog(
      context: context,
      builder: (_) => AddEditLinkDialog(link: link),
    );
  }

  Future<void> _deleteLink(String linkId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Link?'),
        content: const Text('Apakah Anda yakin ingin menghapus link ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await Provider.of<LinkBioService>(
        context,
        listen: false,
      ).deleteLink(linkId);
    }
  }

  Future<void> _toggleActive(LinkBioModel link, bool newVal) async {
    final updated = link.copyWith(isActive: newVal);
    await Provider.of<LinkBioService>(
      context,
      listen: false,
    ).updateLink(updated);
  }

  Future<void> _saveSocialSettings() async {
    if (_currentUser == null) return;
    setState(() => _isSavingSocial = true);
    try {
      final userService = Provider.of<UserService>(context, listen: false);
      await userService.updateUserProfile(_currentUser!.id, {
        'show_jagaddhita_catalog': _showJagaddhita,
        'show_sibi_catalog': _showSibi,
        'whatsapp_number': _whatsappController.text.trim(),
        'instagram_url': _instagramController.text.trim(),
        'tiktok_url': _tiktokController.text.trim(),
        'facebook_url': _facebookController.text.trim(),
      });
      await _loadUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengaturan Kartu Nama berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingSocial = false);
    }
  }

  @override
  void dispose() {
    _whatsappController.dispose();
    _instagramController.dispose();
    _tiktokController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final linkBioService = Provider.of<LinkBioService>(context);
    final productService = Provider.of<ProductService>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: StreamBuilder<List<LinkBioModel>>(
        stream: linkBioService.getLinks(_currentUser!.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final links = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.only(top: 24),
            children: [
              // ── Header Card ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: StreamBuilder<GlobalSettingsModel>(
                  stream: productService.getGlobalSettings(),
                  builder: (context, settingsSnapshot) {
                    String baseUrl;
                    if (kIsWeb) {
                      baseUrl = Uri.base.origin;
                    } else {
                      baseUrl = settingsSnapshot.data?.webBaseUrl ??
                          'https://marketing-jagaddhitamp.web.app';
                    }
                    return LinkBioHeaderCard(
                      user: _currentUser!,
                      links: links,
                      webBaseUrl: baseUrl,
                    );
                  },
                ),
              ),

              // ── Main Content Area ─────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // ── Social & Catalogs Form ──────────────────────────────
                    LinkBioSocialForm(
                      formKey: _socialFormKey,
                      showJagaddhita: _showJagaddhita,
                      showSibi: _showSibi,
                      isSavingSocial: _isSavingSocial,
                      whatsappController: _whatsappController,
                      instagramController: _instagramController,
                      tiktokController: _tiktokController,
                      facebookController: _facebookController,
                      onShowJagaddhitaChanged: (val) {
                        setState(() => _showJagaddhita = val);
                      },
                      onShowSibiChanged: (val) {
                        setState(() => _showSibi = val);
                      },
                      onSave: _saveSocialSettings,
                    ),

                    const SizedBox(height: 32),

                    // ── Custom Links Header Button ──────────────────────────
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 24),
                      child: OutlinedButton.icon(
                        onPressed: () => _showAddEditDialog(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: AppTheme.primaryColor.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: AppTheme.primaryColor.withValues(
                            alpha: 0.05,
                          ),
                        ),
                        icon: const Icon(Icons.add_circle_outline),
                        label: Text(
                          'Tambah Link Custom Baru',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    // ── Custom Links List ───────────────────────────────────
                    ...links.map(
                      (link) => LinkBioCustomLinkCard(
                        link: link,
                        onToggleActive: (val) => _toggleActive(link, val),
                        onEdit: () => _showAddEditDialog(link),
                        onDelete: () => _deleteLink(link.id),
                      ),
                    ),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_link_fab',
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
