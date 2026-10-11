import 'package:flutter_test/flutter_test.dart';
import 'package:jurnfourteen_app/models/notification_permission_status.dart';

void main() {
  test('disabled notification status directs user to app settings', () {
    const status = NotificationPermissionStatus(enabled: false);

    expect(status.title, 'Notifikasi belum aktif');
    expect(status.actionLabel, 'Aktifkan Notifikasi');
    expect(status.needsSettings, isTrue);
  });

  test('enabled notification status offers a test notification', () {
    const status = NotificationPermissionStatus(enabled: true);

    expect(status.title, 'Notifikasi aktif');
    expect(status.actionLabel, 'Kirim Notifikasi Tes');
    expect(status.needsSettings, isFalse);
  });
}
