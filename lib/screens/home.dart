import 'package:app_motoblack_cliente/screens/destinySelection.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Future<Position> _getLocation() async {
  //   return await Geolocator.getCurrentPosition();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Chupa'),
      // ),
      resizeToAvoidBottomInset: false,
      body: FutureBuilder(
          future: Geolocator.getCurrentPosition(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    // mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      Material(
                        child: TextField(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const DestinySelection()));
                          },
                          decoration: const InputDecoration(
                              hintText: 'Vai pra onde?',
                              prefixIcon: Icon(Icons.search),
                              iconColor: Colors.black),
                        ),
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                              target: LatLng(snapshot.data!.latitude,
                                  snapshot.data!.longitude),
                              zoom: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Erro ao obter localização: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 20),
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
