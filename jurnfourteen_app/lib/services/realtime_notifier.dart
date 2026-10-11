import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_notification.dart';
import 'notification_service.dart';
import 'supabase_service.dart';

class RealtimeNotifier {
  RealtimeNotifier._();

  static RealtimeChannel? _channel;
  static String? _memberId;

  static Future<void> start() async {
    final member = await SupabaseService.getCurrentMember();
    final userId = SupabaseService.currentUser?.id;
    if (member == null || userId == null) return;
    if (_channel != null && _memberId == member.id) return;
    await stop();
    _memberId = member.id;
    await NotificationService.init();

    _channel = SupabaseService.client
        .channel('tugas-${member.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'assignments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'assigned_to',
            value: member.id,
          ),
          callback: (payload) {
            final row = payload.newRecord;
            _show(AppNotification.fromAssignment(row));
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final row = payload.newRecord;
            _show(AppNotification.fromDatabase(row));
          },
        )
        .subscribe();
  }

  static Future<void> stop() async {
    final ch = _channel;
    _channel = null;
    _memberId = null;
    if (ch != null) await SupabaseService.client.removeChannel(ch);
  }

  static void _show(AppNotification n) {
    NotificationService.show(n, DateTime.now().millisecondsSinceEpoch.remainder(1 << 30));
  }
}
