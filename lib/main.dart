import 'package:flutter/material.dart';import 'package:syria_store/app/view/app.dart';
import 'package:syria_store/core/di/injector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';import 'package:syria_store/core/env/env.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
Future<void> main() async {WidgetsFlutterBinding.ensureInitialized();
await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
await initializeDependencies();
runApp(const ProviderScope(child: const App()));
}
final supabase = Supabase.instance.client;
