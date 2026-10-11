class AttendanceRecord {
  final String id;
  final String activityId;
  final String response;
  final String finalStatus;
  final String? note;

  const AttendanceRecord({
    required this.id,
    required this.activityId,
    required this.response,
    required this.finalStatus,
    this.note,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: (json['id'] ?? '').toString(),
      activityId: (json['activity_id'] ?? '').toString(),
      response: (json['response'] ?? '').toString(),
      finalStatus: (json['final_status'] ?? 'pending').toString(),
      note: json['note']?.toString(),
    );
  }

  bool get isPending => finalStatus == 'pending';
  bool get isRejected => finalStatus == 'rejected' || finalStatus == 'ditolak';
  bool get isApproved => const {'hadir', 'izin', 'sakit', 'alfa'}.contains(finalStatus);
  bool get canRespond => isPending;

  String get statusLabel {
    if (isPending) return 'Menunggu konfirmasi admin';
    if (isRejected) return 'Ditolak';
    return 'Disetujui: ${finalStatus.toUpperCase()}';
  }
}
