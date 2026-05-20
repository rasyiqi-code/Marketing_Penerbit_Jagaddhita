import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/firestore/user_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/storage_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/network_image_web_helper.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/widgets/app_text_field.dart';
import 'package:provider/provider.dart';

/// Bottom sheet untuk mengedit profil marketing (nama, username, foto, dll.)
Future<void> showEditProfileSheet({
  required BuildContext context,
  required UserModel currentUser,
  required TextEditingController emailController,
  required TextEditingController nameController,
  required TextEditingController usernameController,
  required TextEditingController ktpController,
  required TextEditingController addressController,
  required TextEditingController phoneController,
  required VoidCallback onSaved,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _EditProfileSheet(
      currentUser: currentUser,
      emailController: emailController,
      nameController: nameController,
      usernameController: usernameController,
      ktpController: ktpController,
      addressController: addressController,
      phoneController: phoneController,
      onSaved: onSaved,
    ),
  );
}

class _EditProfileSheet extends StatefulWidget {
  final UserModel currentUser;
  final TextEditingController emailController;
  final TextEditingController nameController;
  final TextEditingController usernameController;
  final TextEditingController ktpController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final VoidCallback onSaved;

  const _EditProfileSheet({
    required this.currentUser,
    required this.emailController,
    required this.nameController,
    required this.usernameController,
    required this.ktpController,
    required this.addressController,
    required this.phoneController,
    required this.onSaved,
  });

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  Uint8List? _newImageBytes;
  String? _newImageFilename;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _newImageBytes = bytes;
          _newImageFilename = image.name;
        });
      }
    } catch (_) {}
  }

  Future<void> _submit() async {
    final name = widget.nameController.text.trim();
    final username = widget.usernameController.text.trim();
    final ktp = widget.ktpController.text.trim();
    final address = widget.addressController.text.trim();
    final phone = widget.phoneController.text.trim();

    if (name.isEmpty) {
      _snack('Nama tidak boleh kosong');
      return;
    }
    if (username.isEmpty) {
      _snack('Username tidak boleh kosong');
      return;
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      _snack('Username hanya huruf, angka, dan garis bawah');
      return;
    }

    setState(() => _isUploading = true);

    try {
      final userService = Provider.of<UserService>(context, listen: false);

      // Check username uniqueness
      if (username != widget.currentUser.username) {
        final exists = await userService.checkUsernameExists(username);
        if (exists) {
          if (mounted) _snack('Username sudah digunakan');
          setState(() => _isUploading = false);
          return;
        }
      }

      String? newPhotoUrl;
      if (_newImageBytes != null) {
        if (!mounted) return;
        final storage = Provider.of<StorageService>(context, listen: false);
        newPhotoUrl = await storage.uploadBytes(
          _newImageBytes!,
          _newImageFilename ?? 'profile.jpg',
          'profile_photos/${widget.currentUser.id}',
        );
      }

      final updateData = <String, dynamic>{
        'name': name,
        'username': username,
        'ktp_number': ktp,
        'address': address,
        'phone_number': phone,
      };
      if (newPhotoUrl != null) updateData['photo_url'] = newPhotoUrl;

      await userService.updateUserProfile(widget.currentUser.id, updateData);

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
      }
    } catch (e) {
      if (mounted) _snack('Error: $e');
      setState(() => _isUploading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit Profil',
              style: GoogleFonts.outfit(
                  fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // ── Photo Picker ──────────────────────────────────────────────
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: _newImageBytes != null
                            ? Image.memory(_newImageBytes!, fit: BoxFit.cover)
                            : (widget.currentUser.photoUrl != null
                                ? NetworkImageWeb(
                                    imageUrl: widget.currentUser.photoUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(Icons.person,
                                    size: 40,
                                    color: Theme.of(context)
                                        .iconTheme
                                        .color
                                        ?.withValues(alpha: 0.5))),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            AppTextField(
              controller: widget.emailController,
              label: 'Alamat Email',
              icon: Icons.email_outlined,
              readOnly: true,
              helperText: 'Email tidak dapat diubah',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: widget.nameController,
              label: 'Nama Lengkap',
              icon: Icons.person_outline,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: widget.usernameController,
              label: 'Username',
              icon: Icons.alternate_email,
              helperText: 'Untuk link bio: jagaddhita.bio/username',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: widget.ktpController,
              label: 'No. KTP',
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: widget.addressController,
              label: 'Alamat Lengkap',
              icon: Icons.home_outlined,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: widget.phoneController,
              label: 'No. WhatsApp / HP',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isUploading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: _isUploading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Simpan Perubahan'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
