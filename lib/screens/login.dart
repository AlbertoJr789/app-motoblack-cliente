import 'package:app_motoblack_cliente/screens/main.dart';
import 'package:app_motoblack_cliente/screens/register.dart';
import 'package:app_motoblack_cliente/widgets/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  void _telaPrincipal(context) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (ctx) => Main()));
  }

  void _telaConfirmarTelefone(context) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (ctx) => Main()));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.asset(
            'assets/pics/moto_black_logo.png',
            width: 300,
          ),
          const SizedBox(
            height: 40,
          ),
          Container(
            width: double.infinity,
            child: const Text(
              'Digite seu e-mail ou nome de usuário: ',
              style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 14,
                  color: Colors.white),
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(
            height: 8.0,
          ),
          const Material(
            child: TextField(),
          ),
          const SizedBox(
            height: 8.0,
          ),
          Container(
            width: double.infinity,
            child: const Text(
              'Digite sua senha: ',
              style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 14,
                  color: Colors.white),
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(
            height: 8.0,
          ),
          const Material(
            child: TextField(),
          ),
          const SizedBox(
            height: 4.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 4, bottom: 4),
            child: Container(
                width: double.infinity,
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                    .push(MaterialPageRoute(builder: (ctx) => Register()));
                   
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
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _telaConfirmarTelefone(context);
              },
              child: const Text(
                'Continuar',
                style: TextStyle(fontSize: 18),
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
    );
  }
}
