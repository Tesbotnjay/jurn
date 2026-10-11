class Member {
  final String id;
  final String fullName;
  final String username;
  final String? email;
  final String? phone;
  final String? kelas;
  final String? divisi;
  final String jabatan;
  final String role;
  final String status;
  final bool isKoor;
  final String? avatarUrl;
  final DateTime createdAt;

  Member({
    required this.id,
    required this.fullName,
    required this.username,
    this.email,
    this.phone,
    this.kelas,
    this.divisi,
    required this.jabatan,
    required this.role,
    required this.status,
    required this.isKoor,
    this.avatarUrl,
    required this.createdAt,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      phone: json['phone'],
      kelas: json['kelas'],
      divisi: json['divisi'],
      jabatan: json['jabatan'] ?? 'Anggota',
      role: json['role'] ?? 'anggota',
      status: json['status'] ?? 'menunggu_verifikasi',
      isKoor: json['is_koor'] ?? false,
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'username': username,
    'email': email,
    'phone': phone,
    'kelas': kelas,
    'divisi': divisi,
    'jabatan': jabatan,
    'role': role,
    'status': status,
    'is_koor': isKoor,
    'avatar_url': avatarUrl,
    'created_at': createdAt.toIso8601String(),
  };
}
