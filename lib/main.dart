import 'package:app_motoblack_cliente/firebase_options.dart';
import 'package:app_motoblack_cliente/screens/home.dart';
import 'package:app_motoblack_cliente/screens/main.dart';
import 'package:app_motoblack_cliente/screens/welcome.dart';
import 'package:app_motoblack_cliente/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login.dart';

void main() async {
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
    return MaterialApp(
      title: 'Moto Black',
      theme: kTheme,
      home: const Login(),
    );
  }
}