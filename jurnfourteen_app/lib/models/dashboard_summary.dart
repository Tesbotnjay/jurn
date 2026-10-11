class DashboardSummary {
  final int hadir;
  final int izin;
  final int sakit;
  final int alfa;
  final int persentase;
  final int total;

  const DashboardSummary({
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.alfa,
    required this.persentase,
    required this.total,
  });

  factory DashboardSummary.fromAttendance(List<Map<String, dynamic>> rows) {
    int hadir = 0;
    int izin = 0;
    int sakit = 0;
    int alfa = 0;

    for (final r in rows) {
      final status = r['final_status'] as String?;
      switch (status) {
        case 'hadir':
          hadir++;
          break;
        case 'izin':
          izin++;
          break;
        case 'sakit':
          sakit++;
          break;
        case 'alfa':
          alfa++;
          break;
      }
    }

    final total = hadir + izin + sakit + alfa;
    final persentase = total > 0 ? ((hadir / total) * 100).round() : 0;

    return DashboardSummary(
      hadir: hadir,
      izin: izin,
      sakit: sakit,
      alfa: alfa,
      persentase: persentase,
      total: total,
    );
  }
}