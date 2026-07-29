import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// عند ربط Firebase الفعلي، فعّل السطرين التاليين بعد تشغيل
// `flutterfire configure` الذي يولّد ملف lib/firebase_options.dart:
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MatajirnaApp()));
}
