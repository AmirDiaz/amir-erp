// Amir ERP — root widget.
// Author: Amir Saoudi.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design_system/tokens/theme.dart';
import 'branding.dart';
import 'router.dart';

class AmirErpApp extends ConsumerWidget {
  const AmirErpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: AmirBranding.appName,
      debugShowCheckedModeBanner: false,
      theme: AmirTheme.light(),
      darkTheme: AmirTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      locale: const Locale('en'),
    );
  }
}
