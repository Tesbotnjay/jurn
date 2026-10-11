import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'router.dart';
import 'services/realtime_notifier.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://waptqzihambwhsqgtuzl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndhcHRxemloYW1id2hzcWd0dXpsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk1NjQ5MjYsImV4cCI6MjEwNTE0MDkyNn0.9EOExWCmZECbFJeXKmOGCJshyauEMZNTS8AsmgFnG4U',
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
  );

  // Init local notifications
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings();
  await notificationsPlugin.initialize(
    settings: const InitializationSettings(android: androidInit, iOS: iosInit),
  );

  // Auto-listen realtime notifications saat session aktif
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    if (data.session != null) {
      RealtimeNotifier.start();
    } else {
      RealtimeNotifier.stop();
    }
  });

  runApp(const JurnFourteenApp());
}

// ─── Neo-Brutalism Color Palette (sama dengan website globals.css) ───────────
class AppColors {
  static const primary    = Color(0xFF1B365D); // --primary
  static const primaryLt  = Color(0xFF2A4A7F); // --primary-light
  static const secondary  = Color(0xFFFFE66D); // --secondary (kuning)
  static const accent     = Color(0xFFFF6B6B); // --accent
  static const bg         = Color(0xFFFFFDF7); // --bg-color (krim)
  static const surface    = Color(0xFFFFFFFF); // --surface
  static const border     = Color(0xFF000000); // --border-color
  static const textMain   = Color(0xFF1A1A1A); // --text-main
  static const textMuted  = Color(0xFF6B7280); // --text-muted
  static const hadir      = Color(0xFF22C55E);
  static const izin       = Color(0xFF3B82F6);
  static const sakit      = Color(0xFF3B82F6);
  static const pending    = Color(0xFFEAB308);
  static const danger     = Color(0xFFEF4444);
}

// ─── Shared Brutalist Widget Helpers ─────────────────────────────────────────
class BrutalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  const BrutalCard({super.key, required this.child, this.padding, this.color});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: color ?? AppColors.surface,
          border: Border.all(color: AppColors.border, width: 2.5),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: AppColors.border, offset: Offset(4, 4), blurRadius: 0)],
        ),
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      );
}

class BrutalButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? bg;
  final Color? fg;
  final bool isLoading;
  const BrutalButton({super.key, required this.onPressed, required this.child, this.bg, this.fg, this.isLoading = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: (isLoading || onPressed == null) ? null : onPressed,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          decoration: BoxDecoration(
            color: (isLoading || onPressed == null) ? AppColors.textMuted : (bg ?? AppColors.primary),
            border: Border.all(color: AppColors.border, width: 2.5),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(color: AppColors.border, offset: Offset(3, 3), blurRadius: 0)],
          ),
          child: isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surface))
              : DefaultTextStyle(
                  style: TextStyle(color: fg ?? AppColors.surface, fontWeight: FontWeight.w900, fontSize: 15),
                  child: child,
                ),
        ),
      );
}

class BrutalInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final bool obscure;
  final TextInputType? keyboardType;
  const BrutalInput({super.key, required this.controller, required this.label, this.hint, this.icon, this.obscure = false, this.keyboardType});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700),
          prefixIcon: icon != null ? Icon(icon, color: AppColors.primary) : null,
          filled: true,
          fillColor: AppColors.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border, width: 2.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
          ),
        ),
      );
}

class JurnFourteenApp extends StatelessWidget {
  const JurnFourteenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'JurnFourteen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.surface,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
          iconTheme: IconThemeData(color: AppColors.surface),
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
