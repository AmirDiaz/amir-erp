// Amir ERP — Flutter universal client entry point.
// Author: Amir Saoudi <amirsaoudi620@gmail.com>
//
// Runs on Android, iOS, Web, Windows, Linux, macOS.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AmirErpApp()));
}
