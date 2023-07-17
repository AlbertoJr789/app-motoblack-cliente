import 'package:app_motoblack_cliente/menu.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moto Black',
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(211, 0, 0, 0),
          brightness: Brightness.dark,
          surface: const Color.fromARGB(255, 197,179, 88),
        ),
        scaffoldBackgroundColor: Color.fromARGB(255, 3, 3, 3),
        textTheme: GoogleFonts.latoTextTheme()
      ),

      home: const Welcome(),
    );
  }
}