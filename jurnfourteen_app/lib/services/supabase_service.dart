import '../models/attendance_record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/member.dart';
import '../models/assignment.dart';
import '../models/drive_link.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  // Auth
  // Website uses username as login ID, mapped to internal Auth email.
  static Future<AuthResponse> signIn(String username, String password) async {
    final authEmail = '${username.trim().toLowerCase()}@jurnfourteen.app';
    return await client.auth.signInWithPassword(
      email: authEmail,
      password: password,
    );
  }

  static Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static User? get currentUser => client.auth.currentUser;

  // Members
  static Future<Member?> getCurrentMember() async {
    final userId = currentUser?.id;
    if (userId == null) return null;

    final response = await client
        .from('members')
        .select()
        .eq('user_id', userId)
        .single();

    return response != null ? Member.fromJson(response) : null;
  }

  static Future<List<Member>> getMembersByDivisi(String divisi) async {
    final response = await client
        .from('members')
        .select()
        .eq('divisi', divisi)
        .eq('status', 'aktif');

    return (response as List).map((json) => Member.fromJson(json)).toList();
  }

  static Future<void> updateMemberDivisi(String memberId, String divisi, bool isKoor) async {
    await client
        .from('members')
        .update({'divisi': divisi, 'is_koor': isKoor})
        .eq('id', memberId);
  }

  // Activities
  static Future<List<Map<String, dynamic>>> getUpcomingActivities() async {
    final response = await client
        .from('activities')
        .select()
        .gte('activity_date', DateTime.now().toIso8601String().split('T')[0])
        .order('activity_date', ascending: true);

    return response;
  }

  // Attendance
  static Future<List<Map<String, dynamic>>> getMyAttendanceRows() async {
    final member = await getCurrentMember();
    if (member == null) return [];
    final response = await client
        .from('attendance')
        .select('final_status')
        .eq('member_id', member.id);
    return List<Map<String, dynamic>>.from(response as List);
  }

  // Fetch full attendance records per activity for detailed status (web parity)
  static Future<List<AttendanceRecord>> getMyAttendanceForActivity(String activityId) async {
    final member = await getCurrentMember();
    if (member == null) return [];
    final response = await client
        .from('attendance')
        .select('id, activity_id, response, final_status, note, submitted_at')
        .eq('member_id', member.id)
        .eq('activity_id', activityId);
    final list = List<Map<String, dynamic>>.from(response as List);
    return list.map(AttendanceRecord.fromJson).toList();
  }

  // Fetch all my attendance rows with activity_id for per-activity status
  static Future<List<AttendanceRecord>> getMyAttendanceRecords() async {
    final member = await getCurrentMember();
    if (member == null) return [];
    final response = await client
        .from('attendance')
        .select('id, activity_id, response, final_status, note')
        .eq('member_id', member.id);
    return List<Map<String, dynamic>>.from(response as List)
        .map(AttendanceRecord.fromJson)
        .toList();
  }

  static Future<void> submitAttendance(String activityId, String responseStatus, {String? note}) async {
    final member = await getCurrentMember();
    if (member == null) return;

    await client.from('attendance').upsert({
      'member_id': member.id,
      'activity_id': activityId,
      'response': responseStatus,
      'note': note,
      'final_status': 'pending',
    });
  }

  static Stream<List<AttendanceRecord>> watchMyAttendanceForActivity(String activityId, String memberId) {
    return client
        .from('attendance')
        .stream(primaryKey: ['id'])
        .eq('activity_id', activityId)
        .map((list) => list
            .where((a) => a['member_id'] == memberId)
            .map(AttendanceRecord.fromJson)
            .toList());
  }

  // Assignments
  static Future<List<Assignment>> getMyAssignments() async {
    final member = await getCurrentMember();
    if (member == null) return [];

    final response = await client
        .from('assignments')
        .select('''
          *,
          assigned_to_name:members!assignments_assigned_to_fkey(full_name)
        ''')
        .eq('assigned_to', member.id)
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      json['assigned_to_name'] = json['assigned_to_name']?['full_name'] ?? 'Unknown';
      return Assignment.fromJson(json);
    }).toList();
  }

  static Future<List<Assignment>> getDivisiAssignments(String divisi) async {
    final response = await client
        .from('assignments')
        .select('''
          *,
          assigned_to_name:members!assignments_assigned_to_fkey(full_name)
        ''')
        .eq('divisi', divisi)
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      json['assigned_to_name'] = json['assigned_to_name']?['full_name'] ?? 'Unknown';
      return Assignment.fromJson(json);
    }).toList();
  }

  static Future<void> createAssignment({
    required String title,
    required String description,
    required String divisi,
    required List<String> memberIds,
    String? activityId,
    DateTime? dueDate,
  }) async {
    final member = await getCurrentMember();
    if (member == null) return;

    for (final memberId in memberIds) {
      await client.from('assignments').insert({
        'title': title,
        'description': description,
        'divisi': divisi,
        'assigned_to': memberId,
        'assigned_by': member.id,
        'activity_id': activityId,
        'due_date': dueDate?.toIso8601String().split('T')[0],
        'status': 'pending',
      });
    }
  }

  static Future<void> updateAssignmentStatus(String assignmentId, String status) async {
    await client
        .from('assignments')
        .update({'status': status})
        .eq('id', assignmentId);
  }

  static Future<void> deleteAssignment(String assignmentId) async {
    await client
        .from('assignments')
        .delete()
        .eq('id', assignmentId);
  }

  static Future<void> deleteDriveLink(String linkId) async {
    await client
        .from('drive_links')
        .delete()
        .eq('id', linkId);
  }

  // Drive Links
  static Future<List<DriveLink>> getDriveLinks() async {
    final response = await client
        .from('drive_links')
        .select('''
          *,
          created_by_name:members!drive_links_created_by_fkey(full_name)
        ''')
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      json['created_by_name'] = json['created_by_name']?['full_name'] ?? 'Unknown';
      return DriveLink.fromJson(json);
    }).toList();
  }

  static Future<void> createDriveLink({
    required String title,
    required String driveUrl,
    required String divisiOwner,
    String? activityId,
    String? description,
  }) async {
    final member = await getCurrentMember();
    if (member == null) throw Exception('Member tidak ditemukan. Login ulang.');

    await client.from('drive_links').insert({
      'title': title,
      'drive_url': driveUrl,
      'divisi_owner': divisiOwner,
      'activity_id': activityId,
      'description': description,
      'created_by': member.id,
    });
  }

  // Broadcasts (pengumuman, sama dengan dashboard web)
  static Future<List<Map<String, dynamic>>> getRecentBroadcasts({int limit = 3}) async {
    final response = await client
        .from('broadcasts')
        .select('id, title, content, created_at')
        .order('created_at', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(response as List);
  }

  // Admin stats (sama dengan dashboard web admin)
  static Future<({int total, int pending})> getMemberCounts() async {
    final all = await client.from('members').select('id');
    final pending = await client.from('members').select('id').eq('status', 'menunggu');
    return (total: (all as List).length, pending: (pending as List).length);
  }

  // Realtime subscriptions
  static RealtimeChannel subscribeToAssignments(Function onEvent) {
    return client
        .channel('assignments_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'assignments',
          callback: (payload) => onEvent(payload),
        )
        .subscribe();
  }

  static RealtimeChannel subscribeToNotifications(Function onEvent) {
    return client
        .channel('notifications_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          callback: (payload) => onEvent(payload),
        )
        .subscribe();
  }
}
