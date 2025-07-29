import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mycafe/controller/auth_controller.dart';
import 'package:mycafe/controller/menu_controller.dart';
import 'package:mycafe/controller/pesanan_controller.dart';
import 'package:mycafe/controller/cart_controller.dart';
import 'package:mycafe/controller/menu_selection_controller.dart';
import 'package:mycafe/view/screen/splash_screen.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Cafe App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          foregroundColor: Colors.white,
        ),
      ),
      initialBinding: AppBinding(),
      home: const SplashScreen(),
    );
  }
}

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<CafeMenuController>(CafeMenuController(), permanent: true);
    Get.put<PesananController>(PesananController(), permanent: true);
    Get.put<CartController>(CartController(), permanent: true);
    Get.put<MenuSelectionController>(MenuSelectionController(), permanent: true);
  }
}