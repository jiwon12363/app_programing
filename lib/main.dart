import 'package:flutter/material.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Firebase.initializeApp() 연동 시 이곳에서 초기화
  runApp(const FridgeApp());
}
