import 'package:flutter/material.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/admin/image_management_screen.dart';
import 'profile_section_header.dart';
import 'profile_settings_tile.dart';

/// Seksi menu setelan pada halaman Profil.
class ProfileMenuSection extends StatelessWidget {
  final bool isAdmin;
  final VoidCallback onOpenEditProfileSheet;
  final VoidCallback onOpenBankSheet;
  final VoidCallback onSignOut;
  final VoidCallback onShowDeleteAccountDialog;

  const ProfileMenuSection({
    super.key,
    required this.isAdmin,
    required this.onOpenEditProfileSheet,
    required this.onOpenBankSheet,
    required this.onSignOut,
    required this.onShowDeleteAccountDialog,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Admin Menu ────────────────────────────────────────────────
        if (isAdmin) ...[
          const ProfileSectionHeader(title: 'Menu Admin'),
          ProfileSettingsTile(
            icon: Icons.inventory_2_outlined,
            title: 'Manajemen Produk',
            subtitle: 'Tambah, edit, atau hapus produk',
            onTap: () => Navigator.pushNamed(context, '/admin/products'),
          ),
          ProfileSettingsTile(
            icon: Icons.settings_outlined,
            title: 'Pengaturan Global',
            subtitle: 'Atur bonus dan variabel sistem',
            onTap: () => Navigator.pushNamed(context, '/admin/settings'),
          ),
          ProfileSettingsTile(
            icon: Icons.image_outlined,
            title: 'Kelola Gambar',
            subtitle: 'Lihat dan hapus gambar',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ImageManagementScreen()),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── Informasi Pribadi ─────────────────────────────────────────
        const ProfileSectionHeader(title: 'Informasi Pribadi'),
        ProfileSettingsTile(
          icon: Icons.person_outline_rounded,
          title: 'Edit Profil',
          subtitle: 'Perbarui nama dan detail pribadi',
          onTap: onOpenEditProfileSheet,
        ),
        const SizedBox(height: 12),

        // ── Detail Pembayaran ─────────────────────────────────────────
        const ProfileSectionHeader(title: 'Detail Pembayaran'),
        ProfileSettingsTile(
          icon: Icons.account_balance_rounded,
          title: 'Informasi Bank',
          subtitle: 'Kelola akun penarikan',
          onTap: onOpenBankSheet,
        ),
        const SizedBox(height: 12),

        // ── Akun ──────────────────────────────────────────────────────
        const ProfileSectionHeader(title: 'Akun'),
        ProfileSettingsTile(
          icon: Icons.logout,
          title: 'Keluar',
          subtitle: 'Keluar dari perangkat ini',
          isRed: true,
          onTap: onSignOut,
        ),
        ProfileSettingsTile(
          icon: Icons.delete_forever_rounded,
          title: 'Hapus Akun',
          subtitle: 'Hapus permanen akun dan data Anda',
          isRed: true,
          onTap: onShowDeleteAccountDialog,
        ),
      ],
    );
  }
}
