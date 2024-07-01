import 'package:app_motoblack_cliente/firebase_options.dart';
import 'package:app_motoblack_cliente/screens/main.dart';
import 'package:app_motoblack_cliente/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );

  //verifica se o usuário já logou
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = await prefs.getString('token');
  runApp(MyApp(login: token != null ? false : true));
}

class MyApp extends StatelessWidget {

  bool? login;

   MyApp({super.key,required this.login});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Moto Black',
      theme: kTheme,
      home:  login! ? Login() : const Main(),
    );
  }
}