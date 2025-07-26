import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mycafe/controller/auth_controller.dart';
import 'package:mycafe/controller/menu_controller.dart';
import 'package:mycafe/controller/pesanan_controller.dart';
import 'package:mycafe/controller/cart_controller.dart';
import 'package:mycafe/view/screen/auth/auth_wrapper.dart';
import 'package:provider/provider.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => CafeMenuController()),
        ChangeNotifierProvider(create: (_) => PesananController()),
        ChangeNotifierProvider(create: (_) => CartController()),
      ],
      child: GetMaterialApp(
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
        home: const AuthWrapper(),
      ),
    );
  }
}