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
  bool _driveMode = false;
  late var _driveRes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: FutureBuilder(
          future: Geolocator.getCurrentPosition(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    Material(
                      child: _driveMode
                          ? const Center(
                              child: Text("Modo Corrida pae:"),
                            )
                          : TextField(
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                _driveRes = await Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (ctx) => DestinySelection(
                                            location: snapshot.data!)));
                                if (_driveRes != null) {
                                  setState(() {
                                    _driveMode = true;
                                  });
                                }
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
                    Expanded(
                      child: _driveMode
                          ? GoogleMap(
                              initialCameraPosition: CameraPosition(
                                  target: LatLng(_driveRes['origin']['lat'],
                                      _driveRes['origin']['lon']),
                                  zoom: 16),
                            )
                          : Container(),
                    ),
                  ],
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
