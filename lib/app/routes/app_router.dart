import 'package:flutter/material.dart';import 'package:go_router/go_router.dart'; import 'package:syria_store/features/splash/presentation/splash_page.dart';
final goRouter = GoRouter(initialLocation: '/', routes: [ GoRoute(path: '/', builder: (context, state) => const SplashPage()), GoRoute(path: '/home', builder: (context, state) => const Scaffold(body: Center(child: Text('Home Page')))),],);
