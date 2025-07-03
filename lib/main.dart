import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/app/routes/app_router.dart';
import 'package:syria_store/core/env/env.dart';
import 'package:syria_store/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // استخدام runZonedGuarded لضمان التقاط جميع الأخطاء
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // --- معالج أخطاء Flutter ---
      // يلتقط الأخطاء التي تحدث داخل إطار عمل Flutter (أثناء بناء الواجهات، التخطيط، الرسم)
      FlutterError.onError = (FlutterErrorDetails details) {
        // طباعة الخطأ وتفاصيله في الكونسول
        FlutterError.dumpErrorToConsole(details);
        // يمكنك هنا إرسال الخطأ إلى خدمة مراقبة مثل Sentry أو Firebase Crashlytics
      };

      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
      );

      runApp(const ProviderScope(child: MyApp()));
    },
    (error, stack) {
      // --- معالج الأخطاء الشامل لـ Dart ---
      // يلتقط الأخطاء التي تحدث خارج إطار عمل Flutter (مثل الأخطاء في async gaps)
      debugPrint('Caught Dart Error: $error');
      debugPrint('Stack trace: $stack');
      // يمكنك هنا أيضًا إرسال الخطأ إلى خدمة المراقبة
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'مفروشات دمشق',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      routerConfig: goRouter,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', ''), // Arabic
        Locale('en', ''), // English
      ],
      locale: const Locale('ar', ''),
    );
  }
}
