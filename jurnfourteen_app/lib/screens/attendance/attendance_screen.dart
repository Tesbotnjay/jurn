import 'package:flutter/material.dart';
import '../../../services/supabase_service.dart';
import '../../../models/attendance_record.dart';
import '../../main.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<Map<String, dynamic>> _activities = [];
  final Map<String, AttendanceRecord> _records = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final activities = await SupabaseService.getUpcomingActivities();
    final records = await SupabaseService.getMyAttendanceRecords();
    if (!mounted) return;
    setState(() {
      _activities = activities;
      _records
        ..clear()
        ..addEntries(records.map((r) => MapEntry(r.activityId, r)));
      _isLoading = false;
    });
  }

  Future<void> _submit(String activityId, String status) async {
    try {
      await SupabaseService.submitAttendance(activityId, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Presensi dikirim, menunggu konfirmasi admin'),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
      await _fetch();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mencatat presensi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _statusBanner(AttendanceRecord? r) {
    if (r == null) return const SizedBox.shrink();
    final color = r.isApproved
        ? AppColors.secondary
        : r.isRejected
            ? AppColors.accent
            : AppColors.primary;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            r.statusLabel,
            style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 13),
          ),
          if (r.isRejected && r.note != null && r.note!.isNotEmpty)
            Text(
              'Alasan: ${r.note}',
              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black, fontSize: 12),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Presensi Kegiatan')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activities.isEmpty
              ? const Center(child: Text('Tidak ada kegiatan mendatang.'))
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _activities.length,
                    itemBuilder: (context, index) {
                      final item = _activities[index];
                      final record = _records[(item['id'] ?? '').toString()];
                      return BrutalCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (item['name'] ?? 'Tanpa Nama Kegiatan').toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 17,
                                  color: AppColors.textMain),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tanggal: ${item['activity_date'] ?? "-"} | Pukul: ${item['start_time'] ?? "-"}',
                              style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w700),
                            ),
                            if (item['description'] != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                item['description'].toString(),
                                style: const TextStyle(
                                    color: AppColors.textMain,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                            const SizedBox(height: 16),
                            if (record != null && record.canRespond) ...[
                              const Text(
                                'Sudah dikirim, menunggu konfirmasi admin',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (record == null || record.canRespond)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _btn('HADIR', () => _submit(item['id'], 'hadir'),
                                      AppColors.primary),
                                  _btn('IZIN', () => _submit(item['id'], 'izin'),
                                      AppColors.secondary),
                                  _btn('SAKIT', () => _submit(item['id'], 'sakit'),
                                      AppColors.accent),
                                ],
                              )
                            else
                              _statusBanner(record),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _btn(String label, VoidCallback onTap, Color color) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      child: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
    );
  }
}
