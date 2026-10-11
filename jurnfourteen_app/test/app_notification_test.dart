import 'package:flutter_test/flutter_test.dart';
import 'package:jurnfourteen_app/models/app_notification.dart';

void main() {
  test('assignment event becomes task notification', () {
    final notification = AppNotification.fromAssignment({
      'id': 'assignment-1',
      'title': 'Foto kegiatan Jumat',
      'description': 'Dokumentasikan seluruh kegiatan.',
    });

    expect(notification.title, 'Tugas Baru');
    expect(notification.body, 'Foto kegiatan Jumat');
    expect(notification.payload, 'assignment:assignment-1');
  });

  test('database notification keeps title message and reference payload', () {
    final notification = AppNotification.fromDatabase({
      'id': 'notification-1',
      'title': 'Kehadiran Diverifikasi',
      'message': 'Presensi Anda diterima.',
      'reference_type': 'attendance',
      'reference_id': 'attendance-1',
    });

    expect(notification.title, 'Kehadiran Diverifikasi');
    expect(notification.body, 'Presensi Anda diterima.');
    expect(notification.payload, 'attendance:attendance-1');
  });
}
