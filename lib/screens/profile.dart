// import 'package:app_motoblack_cliente/widgets/help.dart';
// import 'package:app_motoblack_cliente/widgets/paymentDetails.dart';
import 'package:app_motoblack_cliente/controllers/loginController.dart';
import 'package:app_motoblack_cliente/widgets/profile/profileDetails.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dados Pessoais'),
          actions: [
            Tooltip(message: 'Sair da conta',child: IconButton(onPressed: (){
                 showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Sair da conta'),
                      content: const Text("Quer realmente sair da sua conta?"),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                          },
                          child: const Text('Não'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            LoginController.logoff();
                          },
                          child: const Text('Sim'),
                        )
                      ],
                    ),
                  );
            }, icon: Icon(Icons.logout_outlined,size: 36,)))
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Info. Conta',
              ),
              // Tab(
              //   text: 'Pagamentos',
              // ),
              // Tab(
              //   text: 'Ajuda',
              // ),
            ],
          ),
        ),
        body: const TabBarView(children: [
          ProfileDetails(),
          //  PaymentDetails(),
          //  HelpDetails()
        ]),
      ),
    );
  }
}
