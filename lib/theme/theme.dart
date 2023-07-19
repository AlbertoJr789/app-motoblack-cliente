import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

var kTheme = ThemeData.dark().copyWith(
  textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.black87,
      selectionHandleColor: const Color.fromARGB(255, 197, 179, 88)),
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color.fromARGB(211, 0, 0, 0),
    brightness: Brightness.dark,
    surface: const Color.fromARGB(255, 197, 179, 88),
  ),
  scaffoldBackgroundColor: Color.fromARGB(255, 3, 3, 3),
  textTheme: GoogleFonts.latoTextTheme(),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      textStyle: const TextStyle(color: Colors.white),
      foregroundColor: const Color.fromARGB(211, 0, 0, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color.fromARGB(255, 216, 216, 216),
    border: OutlineInputBorder(
      borderSide: BorderSide(
        color: const Color.fromARGB(211, 0, 0, 0),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: const Color.fromARGB(255, 197, 179, 88),
      ), // Border when TextField is focused
    ),
  ),
  primaryTextTheme: const TextTheme(
    titleLarge: TextStyle(
      color: Colors.white,
      decoration: TextDecoration.none,
    ),
    titleMedium: TextStyle(
      color: Colors.white,
      decoration: TextDecoration.none,  
    ),
    bodyLarge: TextStyle(
      color: Colors.white,
      decoration: TextDecoration.none,  
    ),
  ),
);
