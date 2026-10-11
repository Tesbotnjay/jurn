class Assignment {
  final String id;
  final String title;
  final String description;
  final String divisi;
  final String assignedToId;
  final String assignedToName;
  final String assignedById;
  final String? activityId;
  final DateTime? dueDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.divisi,
    required this.assignedToId,
    required this.assignedToName,
    required this.assignedById,
    this.activityId,
    this.dueDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      divisi: json['divisi'] ?? '',
      assignedToId: json['assigned_to'] ?? '',
      assignedToName: json['assigned_to_name'] ?? 'Unknown',
      assignedById: json['assigned_by'] ?? '',
      activityId: json['activity_id'],
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'divisi': divisi,
    'assigned_to': assignedToId,
    'assigned_by': assignedById,
    'activity_id': activityId,
    'due_date': dueDate?.toIso8601String(),
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
