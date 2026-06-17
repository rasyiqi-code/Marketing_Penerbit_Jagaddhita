import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/auth_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/profile/widgets/bank_settings_sheet.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/profile/widgets/edit_profile_sheet.dart';
import 'package:provider/provider.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/profile_menu_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;

  // Bank controllers
  late final TextEditingController _bankNameController;
  late final TextEditingController _accNumberController;
  late final TextEditingController _holderNameController;
  late final TextEditingController _bankPhoneController;

  // Profile controllers
  late final TextEditingController _emailController;
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _ktpController;
  late final TextEditingController _addressController;
  late final TextEditingController _profilePhoneController;

  @override
  void initState() {
    super.initState();
    _bankNameController = TextEditingController();
    _accNumberController = TextEditingController();
    _holderNameController = TextEditingController();
    _bankPhoneController = TextEditingController();
    _emailController = TextEditingController();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _ktpController = TextEditingController();
    _addressController = TextEditingController();
    _profilePhoneController = TextEditingController();
    _loadUser();
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accNumberController.dispose();
    _holderNameController.dispose();
    _bankPhoneController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _ktpController.dispose();
    _addressController.dispose();
    _profilePhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await Provider.of<AuthService>(context, listen: false)
        .getCurrentUserDetails();
    if (!mounted) return;
    setState(() {
      _currentUser = user;
      _isLoading = false;
      if (user != null) _syncControllers(user);
    });
  }

  void _syncControllers(UserModel user) {
    final bank = user.bankDetails ?? {};
    _bankNameController.text = bank['bank_name'] ?? '';
    _accNumberController.text = bank['account_number'] ?? '';
    _holderNameController.text = bank['account_holder'] ?? '';
    _bankPhoneController.text = bank['phone'] ?? '';
    _emailController.text = user.email;
    _nameController.text = user.name ?? '';
    _usernameController.text = user.username ?? '';
    _ktpController.text = user.ktpNumber ?? '';
    _addressController.text = user.address ?? '';
    _profilePhoneController.text = user.whatsappNumber ?? user.phoneNumber ?? '';
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _openBankSheet() {
    if (_currentUser == null) return;
    showBankSettingsSheet(
      context: context,
      user: _currentUser!,
      bankNameController: _bankNameController,
      accNumberController: _accNumberController,
      holderNameController: _holderNameController,
      phoneController: _bankPhoneController,
      onSaved: _loadUser,
    );
  }

  void _openEditProfileSheet() {
    if (_currentUser == null) return;
    showEditProfileSheet(
      context: context,
      currentUser: _currentUser!,
      emailController: _emailController,
      nameController: _nameController,
      usernameController: _usernameController,
      ktpController: _ktpController,
      addressController: _addressController,
      phoneController: _profilePhoneController,
      onSaved: _loadUser,
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Akun?'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus akun Anda secara permanen? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => _deleteAccount(ctx),
            child: const Text('Hapus Secara Permanen'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext dialogCtx) async {
    Navigator.pop(dialogCtx);
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await Provider.of<AuthService>(context, listen: false).deleteAccount();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun berhasil dihapus.')),
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isAdmin = _currentUser?.role == 'admin';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        children: [
          const SizedBox(height: 10),
          ProfileAvatar(user: _currentUser),
          const SizedBox(height: 8),
          Text(
            _currentUser?.name ?? _currentUser?.email ?? 'Unknown User',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (_currentUser?.username != null)
            Text(
              '@${_currentUser!.username}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          Text(
            _currentUser?.role.toUpperCase() ?? 'USER',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),

          ProfileMenuSection(
            isAdmin: isAdmin,
            onOpenEditProfileSheet: _openEditProfileSheet,
            onOpenBankSheet: _openBankSheet,
            onSignOut: () async {
              await Provider.of<AuthService>(context, listen: false).signOut();
            },
            onShowDeleteAccountDialog: _showDeleteAccountDialog,
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

