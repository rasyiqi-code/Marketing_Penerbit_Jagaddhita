import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/global_settings_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/link_bio_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/auth_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/link_bio_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/product_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/user_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/link_bio/add_edit_link_dialog.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/link_bio/widgets/link_bio_admin_widgets.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/link_bio/widgets/link_delete_dialog.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/link_bio/widgets/link_bio_custom_links_section.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/app_dialogs.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/widgets/async_snapshot_widget.dart';

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
      builder: (ctx) => const LinkDeleteDialog(),
    );

    if (confirm == true && mounted) {
      await Provider.of<LinkBioService>(context, listen: false).deleteLink(linkId);
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
        AppDialogs.showSuccessSnackBar(context, 'Pengaturan Kartu Nama berhasil disimpan!');
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showErrorSnackBar(context, 'Gagal menyimpan: $e');
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder<List<LinkBioModel>>(
        stream: linkBioService.getLinks(_currentUser!.id),
        builder: (context, snapshot) {
          return AsyncSnapshotWidget<List<LinkBioModel>>(
            snapshot: snapshot,
            builder: (context, links) {
              return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            children: [
              // ── Header Card ───────────────────────────────────────────────
              StreamBuilder<GlobalSettingsModel>(
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

              const SizedBox(height: 8),

              // ── Main Content Area ─────────────────────────────────────────
              LinkBioCustomLinksSection(
                socialFormKey: _socialFormKey,
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
                links: links,
                onAddLink: () => _showAddEditDialog(),
                onToggleActive: (link) => _toggleActive(link, !link.isActive),
                onEdit: (link) => _showAddEditDialog(link),
                onDelete: (link) => _deleteLink(link.id),
              ),
            ],
          );
        },
      );
    },
  ),
    );
  }
}
