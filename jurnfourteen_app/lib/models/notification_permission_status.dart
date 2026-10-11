class NotificationPermissionStatus {
  final bool enabled;

  const NotificationPermissionStatus({required this.enabled});

  String get title => enabled ? 'Notifikasi aktif' : 'Notifikasi belum aktif';

  String get actionLabel => enabled ? 'Kirim Notifikasi Tes' : 'Aktifkan Notifikasi';

  bool get needsSettings => !enabled;
}