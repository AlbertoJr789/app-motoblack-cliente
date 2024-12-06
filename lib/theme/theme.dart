import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


const _primaryColor = const Color.fromARGB(255, 197, 179, 88);
const _sencondaryColor =  const Color.fromARGB(255, 3, 3, 3);
const _dangerColor = Color.fromARGB(210, 182, 21, 21);
const _inversePrimary = Color.fromARGB(255, 216, 216, 216);

var kTheme = ThemeData.dark().copyWith(
  appBarTheme: const AppBarTheme(
    titleTextStyle: TextStyle(color: _sencondaryColor, fontSize: 24),
    iconTheme: IconThemeData(color: _sencondaryColor, size: 24),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: _sencondaryColor,
    selectionHandleColor: _primaryColor,
  ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: _sencondaryColor,
    inversePrimary: _inversePrimary,
    brightness: Brightness.dark,
    surface: _primaryColor,
  ),
  scaffoldBackgroundColor: _sencondaryColor,
  textTheme: GoogleFonts.latoTextTheme(),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      textStyle: const TextStyle(color: Colors.white),
      foregroundColor: _sencondaryColor,
      backgroundColor: _primaryColor,
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
        color: _sencondaryColor,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: _dangerColor,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: _dangerColor,
      ),
    ),
    errorStyle: TextStyle(
      color: _dangerColor,
    ),
    labelStyle: TextStyle(
      fontSize: 18,
      color: _sencondaryColor,
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: _primaryColor,
      ), // Border when TextField is focused
    ),
    hintStyle: TextStyle(color: _sencondaryColor, fontSize: 18),
    iconColor: _sencondaryColor,
    prefixIconColor: _sencondaryColor,
  ),
  primaryColor: _primaryColor,
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: _primaryColor,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: _primaryColor,
  ),
  dialogTheme: DialogTheme(backgroundColor: Colors.white),
  tabBarTheme: const TabBarTheme(
  labelColor: _sencondaryColor,
  unselectedLabelColor: _sencondaryColor,
  indicator: UnderlineTabIndicator(
    borderSide: BorderSide(color: _sencondaryColor, width: 2.0),
    insets: EdgeInsets.symmetric(horizontal: 16.0),
  ),)
);
