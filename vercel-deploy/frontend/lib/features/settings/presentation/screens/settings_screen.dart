import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/domain/auth_providers.dart';
import '../../../../core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _obscurePassword = true;
  bool _obscureNewPassword = true;
  bool _isLoading = false;

  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  final _nameCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image == null) return;

      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mengunggah foto...')),
        );
      }

      // Convert to base64
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Update profile
      await ref.read(authNotifierProvider.notifier).updateProfile(
        avatarBase64: base64Image,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diperbarui!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload foto: $e')),
        );
      }
    }
  }

  void _showEditNameDialog(String currentName) {
    _nameCtrl.text = currentName;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Nama'),
        content: TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Nama',
            hintText: 'Masukkan nama baru',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nameCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama tidak boleh kosong')),
                );
                return;
              }
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).updateProfile(
                name: _nameCtrl.text.trim(),
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama berhasil diperbarui!')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _currentPasswordCtrl,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password Saat Ini',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordCtrl,
              obscureText: _obscureNewPassword,
              decoration: InputDecoration(
                labelText: 'Password Baru',
                suffixIcon: IconButton(
                  icon: Icon(_obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi Password Baru',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _changePassword,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Ubah'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword() async {
    if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password tidak cocok')),
      );
      return;
    }

    if (_newPasswordCtrl.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 8 karakter')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Implement API call for password change
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil diubah!')),
        );
        _currentPasswordCtrl.clear();
        _newPasswordCtrl.clear();
        _confirmPasswordCtrl.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name, String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      try {
        final bytes = base64Decode(avatarUrl);
        return CircleAvatar(
          radius: 50,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (_) {
        // Fallback to initials
      }
    }
    return CircleAvatar(
      radius: 50,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Text(
        (name.isNotEmpty ? name[0] : '?').toUpperCase(),
        style: const TextStyle(
          fontSize: 40,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          // Profile Section
          Consumer(
            builder: (context, ref, child) {
              final authState = ref.watch(authNotifierProvider);

              String name = '';
              String email = '';
              String? avatar;

              authState.whenData((state) {
                if (state is Authenticated) {
                  name = state.user.name ?? '';
                  email = state.user.email ?? '';
                  avatar = state.user.avatar;
                }
              });

              return Column(
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      _buildAvatar(name, avatar),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickAndUploadAvatar,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name.isNotEmpty ? name : 'Pengguna',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (email.isNotEmpty)
                    Text(
                      email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),
          const Divider(),

          // Edit Profile Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Edit Profil',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Consumer(
            builder: (context, ref, child) {
              final authState = ref.watch(authNotifierProvider);
              String name = '';
              authState.whenData((state) {
                if (state is Authenticated) {
                  name = state.user.name ?? '';
                }
              });

              return ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Ubah Nama'),
                subtitle: Text(name.isNotEmpty ? name : 'Belum diatur'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showEditNameDialog(name),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Ubah Foto Profil'),
            subtitle: const Text('Pilih foto dari galeri'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickAndUploadAvatar,
          ),

          const Divider(),

          // Appearance Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Tampilan',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SwitchListTile(
            secondary: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Mode Gelap'),
            subtitle: Text(isDarkMode ? 'Tema gelap aktif' : 'Tema terang aktif'),
            value: isDarkMode,
            onChanged: (value) {
              ref.read(themeNotifierProvider.notifier).toggleTheme();
            },
          ),

          const Divider(),

          // Account Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Akun',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Ubah Password'),
            subtitle: const Text('Update password akun Anda'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showChangePasswordDialog,
          ),

          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text(
              'Hapus Akun',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('Hapus akun secara permanen'),
            trailing: const Icon(Icons.chevron_right, color: Colors.red),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hubungi support untuk menghapus akun'),
                ),
              );
            },
          ),

          const Divider(),

          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Aksi',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _logout,
          ),

          const SizedBox(height: 24),

          // App Info
          Center(
            child: Column(
              children: [
                Text(
                  'DNTrip v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dibuat dengan ❤️',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
