import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

var kTheme = ThemeData.dark().copyWith(
  appBarTheme: const AppBarTheme(
    titleTextStyle: TextStyle(color: Colors.black87, fontSize: 24),
    iconTheme: IconThemeData(color: Colors.black87, size: 24),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.black87,
    selectionHandleColor: const Color.fromARGB(255, 197, 179, 88),
  ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(211, 0, 0, 0),
    brightness: Brightness.dark,
    surface: const Color.fromARGB(255, 197, 179, 88),
  ),
  scaffoldBackgroundColor: const Color.fromARGB(255, 3, 3, 3),
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
        color: Color.fromARGB(211, 0, 0, 0),
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color.fromARGB(210, 182, 21, 21),
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color.fromARGB(210, 182, 21, 21),
      ),
    ),
    errorStyle: TextStyle(
      color: Color.fromARGB(210, 182, 21, 21),
    ),
    labelStyle: TextStyle(
      fontSize: 18,
      color: Color.fromARGB(211, 0, 0, 0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color.fromARGB(255, 197, 179, 88),
      ), // Border when TextField is focused
    ),
    hintStyle: TextStyle(color: Color.fromARGB(211, 0, 0, 0), fontSize: 18),
    iconColor: Color.fromARGB(211, 0, 0, 0),
    prefixIconColor: Color.fromARGB(211, 0, 0, 0),
  ),
  primaryColor: const Color.fromARGB(255, 197, 179, 88),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Color.fromARGB(255, 197, 179, 88),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: Color.fromARGB(255, 197, 179, 88),
  ),
  dialogTheme: DialogTheme(backgroundColor: Colors.white),
  tabBarTheme: const TabBarTheme(
  labelColor: Colors.black,
  unselectedLabelColor: Colors.black54,
  indicator: UnderlineTabIndicator(
    borderSide: BorderSide(color: Colors.black, width: 2.0),
    insets: EdgeInsets.symmetric(horizontal: 16.0),
  ),)
);
