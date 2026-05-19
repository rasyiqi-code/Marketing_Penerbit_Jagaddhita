import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/auth_service.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/theme/app_theme.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/utils/network_image_web_helper.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/image_management_screen.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/profile/widgets/bank_settings_sheet.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/profile/widgets/edit_profile_sheet.dart';
import 'package:provider/provider.dart';

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
    _profilePhoneController.text = user.phoneNumber ?? '';
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
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _ProfileAvatar(user: _currentUser),
          const SizedBox(height: 16),
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
          const SizedBox(height: 32),

          // ── Admin Menu ────────────────────────────────────────────────
          if (isAdmin) ...[
            _SectionHeader('Menu Admin'),
            _SettingsTile(
              icon: Icons.inventory_2_outlined,
              title: 'Manajemen Produk',
              subtitle: 'Tambah, edit, atau hapus produk',
              onTap: () => Navigator.pushNamed(context, '/admin/products'),
            ),
            _SettingsTile(
              icon: Icons.settings_outlined,
              title: 'Pengaturan Global',
              subtitle: 'Atur bonus dan variabel sistem',
              onTap: () => Navigator.pushNamed(context, '/admin/settings'),
            ),
            _SettingsTile(
              icon: Icons.image_outlined,
              title: 'Kelola Gambar',
              subtitle: 'Lihat dan hapus gambar',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ImageManagementScreen()),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ── Informasi Pribadi ─────────────────────────────────────────
          _SectionHeader('Informasi Pribadi'),
          _SettingsTile(
            icon: Icons.person_outline_rounded,
            title: 'Edit Profil',
            subtitle: 'Perbarui nama dan detail pribadi',
            onTap: _openEditProfileSheet,
          ),
          const SizedBox(height: 24),

          // ── Detail Pembayaran ─────────────────────────────────────────
          _SectionHeader('Detail Pembayaran'),
          _SettingsTile(
            icon: Icons.account_balance_rounded,
            title: 'Informasi Bank',
            subtitle: 'Kelola akun penarikan',
            onTap: _openBankSheet,
          ),
          const SizedBox(height: 24),

          // ── Akun ──────────────────────────────────────────────────────
          _SectionHeader('Akun'),
          _SettingsTile(
            icon: Icons.logout,
            title: 'Keluar',
            subtitle: 'Keluar dari perangkat ini',
            isRed: true,
            onTap: () async {
              await Provider.of<AuthService>(context, listen: false).signOut();
            },
          ),
          _SettingsTile(
            icon: Icons.delete_forever_rounded,
            title: 'Hapus Akun',
            subtitle: 'Hapus permanen akun dan data Anda',
            isRed: true,
            onTap: _showDeleteAccountDialog,
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

// ── Local UI widgets (simple enough to stay in-file) ──────────────────────────

class _ProfileAvatar extends StatelessWidget {
  final UserModel? user;
  const _ProfileAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: user?.photoUrl != null
            ? NetworkImageWeb(imageUrl: user!.photoUrl!, fit: BoxFit.cover)
            : Center(
                child: Text(
                  (user?.email ?? 'U').substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isRed;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isRed = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isRed ? Colors.red : AppTheme.primaryColor;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
