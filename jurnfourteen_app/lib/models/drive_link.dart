class DriveLink {
  final String id;
  final String title;
  final String driveUrl;
  final String divisiOwner;
  final String? activityId;
  final String? description;
  final String createdById;
  final String createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  DriveLink({
    required this.id,
    required this.title,
    required this.driveUrl,
    required this.divisiOwner,
    this.activityId,
    this.description,
    required this.createdById,
    required this.createdByName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DriveLink.fromJson(Map<String, dynamic> json) {
    return DriveLink(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      driveUrl: json['drive_url'] ?? '',
      divisiOwner: json['divisi_owner'] ?? '',
      activityId: json['activity_id'],
      description: json['description'],
      createdById: json['created_by'] ?? '',
      createdByName: json['created_by_name'] ?? 'Unknown',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'drive_url': driveUrl,
    'divisi_owner': divisiOwner,
    'activity_id': activityId,
    'description': description,
    'created_by': createdById,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
