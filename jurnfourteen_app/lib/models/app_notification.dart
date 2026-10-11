class AppNotification {
  final String title;
  final String body;
  final String payload;

  const AppNotification({required this.title, required this.body, required this.payload});

  factory AppNotification.fromAssignment(Map<String, dynamic> row) => AppNotification(
        title: 'Tugas Baru',
        body: (row['title'] ?? 'Penugasan baru').toString(),
        payload: 'assignment:${row['id']}',
      );

  factory AppNotification.fromDatabase(Map<String, dynamic> row) => AppNotification(
        title: (row['title'] ?? 'Notifikasi').toString(),
        body: (row['message'] ?? '').toString(),
        payload: '${row['reference_type'] ?? 'notification'}:${row['reference_id'] ?? row['id']}',
      );
}
