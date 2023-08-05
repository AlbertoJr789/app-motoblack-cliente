import 'package:app_motoblack_cliente/screens/activityDetails.dart';
import 'package:flutter/material.dart';

class Activities extends StatefulWidget {
  const Activities({super.key});

  @override
  State<Activities> createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Atividades mais recentes'),
      ),
      body: ListView.builder(
        itemCount: 12,
        itemBuilder: (ctx, index) => Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: const Color.fromARGB(255, 197, 179, 88),
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ActivityDetails()));
            },
            child: Card(
              shadowColor: const Color.fromARGB(255, 197, 179, 88),
              color: const Color.fromARGB(243, 221, 221, 219),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [
                  Container(
                    width: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Mototaxista Responsável',
                          textAlign: TextAlign.center,
                        ),
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue,
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Corrida 08/03/2022 10:00'),
                        Text('Rua Jote Correa 18 - Rua Jote Correa 28 '),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.arrow_right,color: Colors.black,),
                    ],
                  )
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
