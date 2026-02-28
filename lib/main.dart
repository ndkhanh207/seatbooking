import 'package:get/get.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:movie_ticket/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:movie_ticket/controller/auth_controller.dart';
import 'package:movie_ticket/controller/movie_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(AuthController());
  Get.put(MovieController());
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
