
import 'package:app_motoblack_cliente/models/Activity.dart';
import 'package:app_motoblack_cliente/screens/destinySelection.dart';
import 'package:app_motoblack_cliente/widgets/trip.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {

  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool _driveMode = false;
  late var _driveRes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Material(
              child: _driveMode
                  ? Trip(trip: _driveRes,endTripAction: _endTripDialog) : TextField(
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        _driveRes = await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (ctx) => DestinySelection()));
                        if (_driveRes is Activity) {
                          setState(() {
                            _driveMode = true;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                          hintText: 'Vai pra onde?',
                          prefixIcon: Icon(Icons.search),
                          iconColor: Colors.black),
                          readOnly: true,
                    ),
            ),
            
          ],
        ),
      ),
    );
  }

  void _endTripDialog(){
      showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tem certeza que deseja cancelar a corrida ?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _driveMode = false;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Sim'),
          ),
        ],
      ),
    );
  }

}
