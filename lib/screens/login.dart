import 'package:app_motoblack_cliente/controllers/loginController.dart';
import 'package:app_motoblack_cliente/screens/main.dart';
import 'package:app_motoblack_cliente/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final TextEditingController _user = TextEditingController();
  final TextEditingController _password = TextEditingController();
  late LoginController _controller;
  final _formKey = GlobalKey<FormState>();
  bool _isLoggingIn = false;

  void _telaPrincipal(context) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (ctx) => Main()));
  }

  void _login(context) async {
    if(_formKey.currentState!.validate()){
      setState(() {
        _isLoggingIn = true;
      });
      if(await _controller.login(_user.text, _password.text)){
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (ctx) => const Main()));
      }else{
        _formKey.currentState!.reset();
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _controller = LoginController(context);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Image.asset(
                'assets/pics/moto_black_logo.png',
                width: 300,
              ),
              const SizedBox(
                height: 40,
              ),
              TextFormField(
                controller: _user,
                decoration: const InputDecoration(
                  label: Text(
                    'Digite seu e-mail ou nome de usuário',
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 14,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1) {
                    return 'Digite um e-mail ou nome de usuário válido';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 8.0,
              ),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  label: Text(
                    'Digite sua senha',
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 14,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 8) {
                    return 'Digite uma senha válida com pelo menos 8 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 8.0,
              ),
              Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4),
                child: Container(
                    width: double.infinity,
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (ctx) => Register()));
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Não tem conta ainda?',
                          style: TextStyle(
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                              color: Theme.of(context).colorScheme.surface),
                        ),
                      ),
                    )),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: !_isLoggingIn ? () {
                    _login(context);
                  } : null,
                  child: !_isLoggingIn ? const Text(
                    'Continuar',
                    style: TextStyle(fontSize: 18),
                  ) : const Padding(
                    padding: EdgeInsets.all(8.0),
                    child:  CircularProgressIndicator(color: Colors.black,),
                  ),
                ),
              ),
              const Center(
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.white60,
                        thickness: 0.5,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Ou, se preferir',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            decoration: TextDecoration.none),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.white60,
                        thickness: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _telaPrincipal(context);
                  },
                  icon: SvgPicture.asset(
                    'assets/logos/google.svg',
                    semanticsLabel: 'logoGoogle',
                    height: 18,
                    width: 18,
                  ),
                  label: const Text(
                    'Entre com o Google',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(
                height: 4.0,
              ),
              Container(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _telaPrincipal(context);
                  },
                  icon: SvgPicture.asset(
                    'assets/logos/facebook.svg',
                    semanticsLabel: 'logoFacebook',
                    height: 18,
                    width: 18,
                  ),
                  label: const Text(
                    'Entre com o Facebook',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    _user.dispose();
    _password.dispose();
    super.dispose();   
  }
}
