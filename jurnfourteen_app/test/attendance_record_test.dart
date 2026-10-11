import 'package:flutter_test/flutter_test.dart';
import 'package:jurnfourteen_app/models/attendance_record.dart';

void main() {
  test('approved attendance exposes final status and approved label', () {
    final record = AttendanceRecord.fromJson({
      'id': 'att-1',
      'activity_id': 'act-1',
      'response': 'hadir',
      'final_status': 'hadir',
      'note': null,
    });

    expect(record.isApproved, isTrue);
    expect(record.statusLabel, 'Disetujui: HADIR');
    expect(record.canRespond, isFalse);
  });

  test('pending attendance remains changeable and shows waiting label', () {
    final record = AttendanceRecord.fromJson({
      'id': 'att-2',
      'activity_id': 'act-1',
      'response': 'sakit',
      'final_status': 'pending',
    });

    expect(record.isPending, isTrue);
    expect(record.statusLabel, 'Menunggu konfirmasi admin');
    expect(record.canRespond, isTrue);
  });

  test('rejected attendance exposes admin note', () {
    final record = AttendanceRecord.fromJson({
      'id': 'att-3',
      'activity_id': 'act-1',
      'response': 'izin',
      'final_status': 'rejected',
      'note': 'Bukti izin belum lengkap',
    });

    expect(record.isRejected, isTrue);
    expect(record.statusLabel, 'Ditolak');
    expect(record.note, 'Bukti izin belum lengkap');
    expect(record.canRespond, isFalse);
  });
}
