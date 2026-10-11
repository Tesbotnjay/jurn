import 'package:flutter_test/flutter_test.dart';
import 'package:jurnfourteen_app/models/dashboard_summary.dart';

void main() {
  test('attendance summary counts statuses and rounds percentage', () {
    final summary = DashboardSummary.fromAttendance([
      {'final_status': 'hadir'},
      {'final_status': 'hadir'},
      {'final_status': 'izin'},
      {'final_status': 'sakit'},
      {'final_status': 'alfa'},
      {'final_status': 'pending'},
    ]);

    expect(summary.hadir, 2);
    expect(summary.izin, 1);
    expect(summary.sakit, 1);
    expect(summary.alfa, 1);
    expect(summary.persentase, 40);
  });

  test('attendance summary has zero percentage without final statuses', () {
    final summary = DashboardSummary.fromAttendance([
      {'final_status': 'pending'},
    ]);

    expect(summary.total, 0);
    expect(summary.persentase, 0);
  });
}
