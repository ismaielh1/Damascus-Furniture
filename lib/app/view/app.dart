import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';import 'package:syria_store/app/routes/app_router.dart';
class App extends ConsumerWidget { const App({super.key}); @override Widget build(BuildContext context, WidgetRef ref) { return MaterialApp.router(routerConfig: goRouter, debugShowCheckedModeBanner: false);}}
