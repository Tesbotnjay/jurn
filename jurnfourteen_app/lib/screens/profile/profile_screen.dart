import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/supabase_service.dart';
import '../../../models/member.dart';
import '../../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Member? _member;
  bool _isLoading = true;

  final _divisiOptions = ['Dokumentasi', 'Media', 'Berita', 'Korespondensi', 'Umum'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final member = await SupabaseService.getCurrentMember();
    if (mounted) {
      setState(() {
        _member = member;
        _isLoading = false;
      });
    }
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: BrutalCard(
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w800)),
                  Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SupabaseService.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _member == null
              ? const Center(child: Text('Data anggota tidak ditemukan.'))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: Container(
                        width: 96,
                        height: 96,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          border: Border.all(color: AppColors.border, width: 2.5),
                          shape: BoxShape.circle,
                          boxShadow: const [BoxShadow(color: AppColors.border, offset: Offset(4, 4))],
                        ),
                        child: Text(
                          _member!.fullName.isNotEmpty ? _member!.fullName[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Text(
                        _member!.fullName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textMain),
                      ),
                    ),
                    Center(
                      child: Text(
                        '@${_member!.username}',
                        style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (_member!.isKoor)
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            border: Border.all(color: AppColors.border, width: 2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'KOORDINATOR DIVISI',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.textMain),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    _infoRow(Icons.badge, 'Jabatan', _member!.jabatan),
                    _infoRow(Icons.groups, 'Divisi', _member!.divisi ?? 'Belum ditentukan'),
                    _infoRow(Icons.email_outlined, 'Email', _member!.email ?? '-'),
                    _infoRow(Icons.school, 'Kelas', _member!.kelas ?? '-'),
                    _infoRow(Icons.verified_user, 'Status', _member!.status),
                    const SizedBox(height: 24),
                    BrutalButton(
                      bg: AppColors.accent,
                      fg: AppColors.border,
                      onPressed: () async {
                        await SupabaseService.signOut();
                        if (context.mounted) context.go('/login');
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.logout, color: AppColors.border), SizedBox(width: 8), Text('Keluar')],
                      ),
                    ),
                  ],
                ),
    );
  }
}
