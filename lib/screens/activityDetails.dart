import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ActivityDetails extends StatelessWidget {
  const ActivityDetails({super.key});
  // latitude = -20.461858529051117;
  // longitude = -45.43592934890276;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Atividade'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.4,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(-20.461858529051117, -45.43592934890276),
                  zoom: 12,
                ),
              ),
            ),
            Container(
              color: Color.fromARGB(243, 255, 255, 254),
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '05/08/2023 às 8:30 até 05/08/2023 às 9:00',
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          'R\$10,00',
                          style: TextStyle(fontSize: 18),
                        )
                      ],
                    ),
                    Divider(
                      color: Color.fromARGB(153, 126, 124, 124),
                      thickness: 0.5,
                    ),
                    Text(
                      'Origem: Rua Jote Correa 18',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Destino: Rua Jote Correa 28',
                      style: TextStyle(fontSize: 18),
                    ),
                    Divider(
                      color: Color.fromARGB(153, 126, 124, 124),
                      thickness: 0.5,
                    ),
                    Text(
                      'Observações relatadas: ui dolorem ipsum, quia dolor sit amet consectetur adipisci velit, sed quia non numquam eius modi tempora incidunt, ut labore et dolore magnam aliquam quaerat voluptatemui dolorem ipsum, quia dolor sit amet consectetur adipisci velit, sed quia non numquam eius modi tempora incidunt, ut labore et dolore magnam aliquam quaerat voluptatem',
                      style: TextStyle(fontSize: 18),
                    ),
                    Divider(
                      color: Color.fromARGB(153, 126, 124, 124),
                      thickness: 0.5,
                    ),
                    Row(children: [
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
                            Text('Arlindo de Souza Arantes'),
                            Text('Veículo HYJ-9486'),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [Text('Nota'), Text('☆☆☆☆☆')],
                      )
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
