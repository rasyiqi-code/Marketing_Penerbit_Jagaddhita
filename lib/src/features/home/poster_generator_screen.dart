import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/auth_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/poster_generator_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/poster_export_helper.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/poster_image_helper.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/home/widgets/poster_generator_widgets.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'widgets/poster/poster_edit_contact_dialog.dart';
import 'widgets/poster/poster_style_panel.dart';
import 'package:image/image.dart' as img;

class PosterGeneratorScreen extends StatefulWidget {
  final String? initialImageUrl;

  const PosterGeneratorScreen({super.key, this.initialImageUrl});

  @override
  State<PosterGeneratorScreen> createState() => _PosterGeneratorScreenState();
}

class _PosterGeneratorScreenState extends State<PosterGeneratorScreen> {
  final _service = PosterGeneratorService();
  bool _isLoading = false;
  Uint8List? _originalImageBytes;
  UserModel? _user;
  bool _initialized = false;

  // Contact info state
  String _name = '';
  String _phone = '';

  // Styling state
  Color _textColor = Colors.white;
  Color _bgColor = const Color(0xFF333333);
  double _bgOpacity = 0.8;
  bool _isBgEnabled = true;
  int _fontTier = 2; // 1: Small, 2: Medium, 3: Large

  // Draggable position (relative)
  double _relativeX = 0.3;
  double _relativeY = 0.7;
  final GlobalKey _imageKey = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _loadUserAndProcessInitial();
      _initialized = true;
    }
  }

  Future<void> _loadUserAndProcessInitial() async {
    setState(() => _isLoading = true);

    final args = ModalRoute.of(context)?.settings.arguments;
    final String? urlFromArgs = args is String ? args : widget.initialImageUrl;

    final authService = Provider.of<AuthService>(context, listen: false);
    _user = await authService.getCurrentUserDetails();

    if (_user != null) {
      _name = _user!.name ?? '-';
      _phone = _user!.phoneNumber ?? '-';
    }

    if (urlFromArgs != null) {
      await _fetchImageFromUrl(urlFromArgs);
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchImageFromUrl(String url) async {
    setState(() => _isLoading = true);
    try {
      String finalUrl = url;
      if (url.contains('r2.cloudflarestorage.com')) {
        try {
          final uri = Uri.parse(url);
          final segments = uri.pathSegments;
          if (segments.length > 1) {
            final objectPath = segments.sublist(1).join('/').split('?').first;
            finalUrl = 'https://poster.librarypenerbitjagaddhita.science/$objectPath';
          }
        } catch (_) {}
      }

      final response = await http.get(Uri.parse(finalUrl));
      if (response.statusCode == 200) {
        setState(() {
          _originalImageBytes = response.bodyBytes;
          _relativeX = 0.3;
          _relativeY = 0.7;
        });
        _showEditDialog();
      } else {
        throw Exception('HTTP status ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat gambar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _originalImageBytes = bytes;
        _relativeX = 0.3;
        _relativeY = 0.7;
      });
      _showEditDialog();
    }
  }

  void _showEditDialog() async {
    final result = await showDialog<(String, String)>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PosterEditContactDialog(
        initialName: _name,
        initialPhone: _phone,
      ),
    );

    if (result != null) {
      setState(() {
        _name = result.$1;
        _phone = result.$2;
      });
    }
  }

  void _showStylePanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => PosterStylePanel(
        initialTextColor: _textColor,
        initialBgColor: _bgColor,
        initialBgOpacity: _bgOpacity,
        initialIsBgEnabled: _isBgEnabled,
        initialFontTier: _fontTier,
        onTextColorChanged: (col) => setState(() => _textColor = col),
        onBgColorChanged: (col) => setState(() => _bgColor = col),
        onBgOpacityChanged: (val) => setState(() => _bgOpacity = val),
        onIsBgEnabledChanged: (val) => setState(() => _isBgEnabled = val),
        onFontTierChanged: (tier) => setState(() => _fontTier = tier),
      ),
    );
  }

  Future<void> _processAndDownloadPoster() async {
    if (_originalImageBytes == null) return;

    setState(() => _isLoading = true);

    try {
      final RenderBox? renderBox =
          _imageKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) throw Exception('RenderBox tidak ditemukan');

      final originalImage = img.decodeImage(_originalImageBytes!);
      if (originalImage == null) throw Exception('Gagal mendekode gambar asli');

      final originalSize = Size(
        originalImage.width.toDouble(),
        originalImage.height.toDouble(),
      );
      final displaySize = renderBox.size;

      final coords = PosterImageHelper.calculateRelativeCoordinates(
        originalSize: originalSize,
        displaySize: displaySize,
        relativeX: _relativeX,
        relativeY: _relativeY,
      );

      final double dxRelative = coords['dx']!;
      final double dyRelative = coords['dy']!;
      final double scale = coords['scale']!;

      final double M = 1.0 / scale;
      final double logicFontSize = _fontTier == 3
          ? 24
          : (_fontTier == 2 ? 16 : 10);

      final Uint8List overlayBytes = await PosterImageHelper.createOverlayImageBytes(
        text: '$_name | WA: $_phone',
        fontSize: logicFontSize * M,
        textColor: _textColor,
        bgColor: _bgColor,
        bgOpacity: _bgOpacity,
        isBgEnabled: _isBgEnabled,
        hPadding: 10 * M,
        vPadding: 6 * M,
        borderRadius: 8 * M,
      );

      final processed = await _service.generatePoster(
        imageBytes: _originalImageBytes!,
        overlayBytes: overlayBytes,
        dx: dxRelative,
        dy: dyRelative,
      );

      if (mounted) {
        final fileName =
            'poster_jagaddhita_${DateTime.now().millisecondsSinceEpoch}.png';
        await PosterExportHelper.exportImage(processed, fileName);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memproses & membagikan poster: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Poster Generator',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_originalImageBytes != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _showEditDialog,
              tooltip: 'Edit Teks',
            ),
            IconButton(
              icon: const Icon(Icons.palette),
              onPressed: _showStylePanel,
              tooltip: 'Gaya Teks',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : _originalImageBytes != null
                  ? _buildEditorStack()
                  : PosterEmptyState(onPickImage: _pickImage),
            ),
          ),
          if (_originalImageBytes != null && !_isLoading)
            PosterBottomActions(
              onPickImage: _pickImage,
              onDownload: _processAndDownloadPoster,
            ),
        ],
      ),
    );
  }

  Widget _buildEditorStack() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double absoluteX = (_relativeX * constraints.maxWidth).clamp(0.0, constraints.maxWidth - 100);
        final double absoluteY = (_relativeY * constraints.maxHeight).clamp(0.0, constraints.maxHeight - 40);

        return Stack(
          alignment: Alignment.center,
          children: [
            Image.memory(
              _originalImageBytes!,
              key: _imageKey,
              fit: BoxFit.contain,
            ),
            Positioned(
              left: absoluteX,
              top: absoluteY,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _relativeX = (_relativeX + details.delta.dx / constraints.maxWidth).clamp(0.0, 1.0);
                    _relativeY = (_relativeY + details.delta.dy / constraints.maxHeight).clamp(0.0, 1.0);
                  });
                },
                child: PosterOverlayText(
                  text: '$_name | WA: $_phone',
                  textColor: _textColor,
                  bgColor: _bgColor,
                  bgOpacity: _bgOpacity,
                  isBgEnabled: _isBgEnabled,
                  fontTier: _fontTier,
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Geser teks ke posisi yang Anda inginkan',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
