class TaskDriveLink {
  final String title;
  final String driveUrl;
  final String description;
  final String divisiOwner;

  const TaskDriveLink({
    required this.title,
    required this.driveUrl,
    required this.description,
    required this.divisiOwner,
  });

  static TaskDriveLink? fromTask({
    required String taskTitle,
    required String url,
    required String description,
    required String divisi,
  }) {
    final value = url.trim();
    if (value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host != 'drive.google.com' && !uri.host.endsWith('.drive.google.com')) {
      throw const FormatException('URL harus berupa link Google Drive');
    }
    return TaskDriveLink(
      title: 'Lampiran tugas: $taskTitle',
      driveUrl: value,
      description: description,
      divisiOwner: divisi,
    );
  }
}
