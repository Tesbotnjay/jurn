import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/supabase_service.dart';
import '../../../models/member.dart';
import '../../main.dart';
import '../../../models/dashboard_summary.dart';
import '../../../models/attendance_record.dart';
import '../../../services/realtime_notifier.dart';
import '../../../services/notification_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Member? _member;
  bool _isLoading = true;
  List<Map<String, dynamic>> _activities = [];
  DashboardSummary? _summary;
  final Map<String, AttendanceRecord> _statusByActivity = {};

  @override
  void initState() {
    super.initState();
    _loadAll();
    RealtimeNotifier.start();
    _checkNotificationPrompt();
  }

  Future<void> _checkNotificationPrompt() async {
    if (!mounted) return;
    final shouldPrompt = await NotificationService.shouldPrompt();
    if (!shouldPrompt || !mounted) return;
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _showNotificationDialog();
    });
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.black, width: 3),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [BoxShadow(offset: Offset(4, 4), color: Colors.black)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🔔 Aktifkan Notifikasi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1B365D)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Dapatkan pemberitahuan langsung saat Anda menerima tugas baru atau update kehadiran.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              _brutalButton('Izinkan', const Color(0xFFFFE66D), () async {
                Navigator.of(ctx).pop();
                final granted = await NotificationService.requestPermission();
                if (!granted) {
                  if (!mounted) return;
                  Future.delayed(const Duration(milliseconds: 600), () {
                    if (!mounted) return;
                    _showManualInstructions();
                  });
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showManualInstructions() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.black, width: 3),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [BoxShadow(offset: Offset(4, 4), color: Colors.black)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '📋 Langkah Manual',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1B365D)),
              ),
              const SizedBox(height: 12),
              const Text(
                '1. Buka Settings → Apps → JurnFourteen\n2. Ketuk “Notifikasi”\n3. Aktifkan “Izinkan notifikasi”',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              _brutalButton('Buka Settings', const Color(0xFF1B365D), () async {
                Navigator.of(ctx).pop();
                await NotificationService.openNotificationSettings();
              }),
              const SizedBox(height: 8),
              _brutalButton('Tutup', Colors.grey.shade300, () => Navigator.of(ctx).pop()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _brutalButton(String label, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(offset: Offset(3, 3), color: Colors.black)],
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      ),
    );
  }

  Future<void> _loadAll() async {
    final member = await SupabaseService.getCurrentMember();
    final activities = await SupabaseService.getUpcomingActivities();
    final attendance = await SupabaseService.getMyAttendanceRows();
    final records = await SupabaseService.getMyAttendanceRecords();
    if (!mounted) return;
    setState(() {
      _member = member;
      _activities = activities.take(5).toList();
      _summary = DashboardSummary.fromAttendance(attendance);
      _statusByActivity
        ..clear()
        ..addEntries(records.map((r) => MapEntry(r.activityId, r)));
      _isLoading = false;
    });
  }

  Widget _statusChip(AttendanceRecord? r) {
    if (r == null) {
      return const Text('Belum absen',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted));
    }
    final color = r.isApproved
        ? AppColors.secondary
        : r.isRejected
            ? AppColors.accent
            : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(r.statusLabel,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black)),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textMain)),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMain)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', width: 28, height: 28),
            const SizedBox(width: 8),
            const Text('JurnFourteen'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Aktifkan notifikasi',
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () async {
              final granted = await NotificationService.requestPermission();
              if (!granted && mounted) _showManualInstructions();
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SupabaseService.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: _loadAll,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // User Card Neo-Brutalist
            BrutalCard(
              color: AppColors.surface,
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      border: Border.all(color: AppColors.border, width: 2),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _member?.fullName.isNotEmpty == true
                          ? _member!.fullName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.border,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _member?.fullName ?? 'Memuat...',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Divisi: ${_member?.divisi ?? "Umum"}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (_member?.isKoor == true)
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              border: Border.all(color: AppColors.border, width: 1.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'KOORDINATOR DIVISI',
                              style: TextStyle(
                                color: AppColors.textMain,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ringkasan absensi (sama dengan dashboard web)
            if (_summary != null)
              BrutalCard(
                color: AppColors.secondary,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat('Hadir', _summary!.hadir.toString()),
                    _stat('Izin', _summary!.izin.toString()),
                    _stat('Sakit', _summary!.sakit.toString()),
                    _stat('Alfa', _summary!.alfa.toString()),
                    _stat('%', '${_summary!.persentase}'),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Kegiatan mendatang
            const Text(
              'KEGIATAN MENDATANG',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 1.0),
            ),
            const SizedBox(height: 10),
            if (_activities.isEmpty)
              const BrutalCard(
                child: Text('Belum ada kegiatan.',
                    style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700)),
              )
            else
              ..._activities.map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: BrutalCard(
                    child: Row(
                      children: [
                        const Icon(Icons.event, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            (a['name'] ?? 'Kegiatan').toString(),
                            style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textMain),
                          ),
                        ),
                        Text(
                          (a['activity_date'] ?? '').toString(),
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 8),
                        _statusChip(_statusByActivity[(a['id'] ?? '').toString()]),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Section Header
            const Text(
              'MENU UTAMA',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppColors.textMuted,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),

            // Grid Menu items
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                _buildMenuItem(
                  context,
                  title: 'Pengumuman',
                  subtitle: 'Broadcast terbaru',
                  icon: Icons.campaign_outlined,
                  accentColor: AppColors.primaryLt,
                  route: '/broadcasts',
                ),
                _buildMenuItem(
                  context,
                  title: 'Absensi',
                  subtitle: 'Presensi kegiatan',
                  icon: Icons.qr_code_scanner,
                  accentColor: AppColors.secondary,
                  route: '/attendance',
                ),
                _buildMenuItem(
                  context,
                  title: 'Penugasan',
                  subtitle: 'Tugas divisi',
                  icon: Icons.assignment_outlined,
                  accentColor: AppColors.accent,
                  route: '/assignments',
                ),
                _buildMenuItem(
                  context,
                  title: 'Link Drive',
                  subtitle: 'Dokumentasi & media',
                  icon: Icons.add_to_drive,
                  accentColor: const Color(0xFF60A5FA),
                  route: '/drive-links',
                ),
                _buildMenuItem(
                  context,
                  title: 'Profil Saya',
                  subtitle: 'Info akun & status',
                  icon: Icons.person_pin_outlined,
                  accentColor: const Color(0xFFC084FC),
                  route: '/profile',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 2.5),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: AppColors.border,
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor,
                border: Border.all(color: AppColors.border, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.border, size: 22),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
