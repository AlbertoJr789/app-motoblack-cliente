import 'package:app_motoblack_cliente/controllers/activityController.dart';
import 'package:app_motoblack_cliente/controllers/destinySelectionController.dart';
import 'package:app_motoblack_cliente/models/Address.dart';
import 'package:app_motoblack_cliente/widgets/assets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../util/util.dart';
import 'dart:async';

class DestinySelection extends StatefulWidget {
  DestinySelection({super.key});

  final TextEditingController origin = TextEditingController();
  final TextEditingController destiny = TextEditingController();
  final FocusNode originfocusNode = FocusNode();
  final FocusNode destinyfocusNode = FocusNode();
  bool firstAddress = true;

  @override
  State<DestinySelection> createState() => _DestinySelectionState();
}

class _DestinySelectionState extends State<DestinySelection> {
  //trip flags
  bool _isInit = false;

  //map address flags
  bool _gettingAddress = false;
  bool _selectingOrigin = false;
  bool _selectingDestiny = true;

  //autocomplete flags
  bool _showAutocomplete = false;
  bool _searchingOrigin = false;
  bool _searchingDestiny = false;
  Timer? _debounce;

  CameraPosition? _currentPosition;
  GoogleMapController? _mapController;

  Address? _originPosition;
  Address? _destinyPosition;

  final DestinySelectionController _destinySelectionController =
      DestinySelectionController();
  final ActivityController _activityController = ActivityController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    widget.origin.text = "Obtendo sua localização...";
    _destinySelectionController.getUserLocation().then((value) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(value.latitude, value.longitude),
            zoom: 16,
          ),
        ),
      );
      _currentPosition =
          CameraPosition(target: LatLng(value.latitude, value.longitude));
      _getAddress();
    }).catchError((error, stackTrace) {
      showAlert(
          context,
          'Tivemos um erro ao obter sua localização!',
          'Digite seu ponto de origem manualmente ou selecione-o no mapa.',
          error.toString());
      _selectingOrigin = true;
      _selectingDestiny = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar corrida'),
      ),
      body: Column(
        children: [
          Column(children: [
            Material(
              child: Container(
                width: double.infinity,
                color: const Color.fromARGB(255, 197, 179, 88),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          height: 70,
                          child: LayoutBuilder(builder: (context, constraints) {
                            return RawAutocomplete<Address>(
                              textEditingController: widget.origin,
                              focusNode: widget.originfocusNode,
                              optionsBuilder: (controller) async {
                                if (controller.text.isEmpty ||
                                    !_showAutocomplete) {
                                  return [];
                                }
                                _showAutocomplete = false;
                                setState(() {
                                  _searchingOrigin = true;
                                });
                                final suggestions = await _getAutocompleteSuggestions(
                                    controller.text);
                                setState(() {
                                  _searchingOrigin = false;
                                });
                                return suggestions;
                              },
                              optionsViewBuilder: (BuildContext context,
                                  AutocompleteOnSelected<Address> onSelected,
                                  Iterable<Address> options) {
                                final scrollController = ScrollController();
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                      elevation: 4.0,
                                      child: Container(
                                        height: MediaQuery.of(context).size.height * 0.2,
                                        width: constraints.biggest.width,
                                        child: Scrollbar(
                                          thumbVisibility: true,
                                          controller: scrollController,
                                          child: ListView(
                                            controller: scrollController,
                                            children:
                                                options.map((Address option) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 4.0),
                                                child: ListTile(
                                                  title: Text(
                                                      option.formattedAddress),
                                                  onTap: () {
                                                    _originPosition = option;
                                                    onSelected(option);
                                                  },
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      )),
                                );
                              },
                              fieldViewBuilder: (BuildContext ctx,
                                  TextEditingController ed,
                                  FocusNode fn,
                                  VoidCallback ofs) {
                                return TextFormField(
                                  controller: ed,
                                  focusNode: fn,
                                  decoration: InputDecoration(
                                    labelText: "Origem",
                                    suffixIcon: _searchingOrigin
                                        ? const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: CircularProgressIndicator(),
                                        )
                                        : const Icon(Icons.search),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    _selectingDestiny = false;
                                    _selectingOrigin = true;
                                  },
                                  onChanged: (_) {
                                    _showAutocomplete = true;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '';
                                    }
                                    if (_originPosition == null)
                                      return 'Ponto de origem inválido!';
                                  },
                                );
                              },
                            );
                          }),
                        ),
                        Container(
                          height: 70,
                          child: LayoutBuilder(builder: (context, constraints) {
                            return RawAutocomplete<Address>(
                              textEditingController: widget.destiny,
                              focusNode: widget.destinyfocusNode,
                              optionsBuilder: (controller) async {
                                if (controller.text.isEmpty ||
                                    !_showAutocomplete) {
                                  return [];
                                }
                                _showAutocomplete = false;
                                setState(() {
                                  _searchingDestiny = true;
                                });
                                final suggestions = await _getAutocompleteSuggestions(
                                    controller.text);
                                setState(() {
                                  _searchingDestiny = false;
                                });
                                return suggestions;
                              },
                              optionsViewBuilder: (BuildContext context,
                                  AutocompleteOnSelected<Address> onSelected,
                                  Iterable<Address> options) {
                                final scrollController = ScrollController();
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                      elevation: 4.0,
                                      child: Container(
                                        height: MediaQuery.of(context).size.height * 0.2,
                                        width: constraints.biggest.width,
                                        child: Scrollbar(
                                          thumbVisibility: true,
                                          controller: scrollController,
                                          child: ListView(
                                            controller: scrollController,
                                            children:
                                                options.map((Address option) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 4.0),
                                                child: ListTile(
                                                  title: Text(
                                                      option.formattedAddress),
                                                  onTap: () {
                                                    _destinyPosition = option;
                                                    onSelected(option);
                                                  },
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      )),
                                );
                              },
                              fieldViewBuilder: (BuildContext ctx,
                                  TextEditingController ed,
                                  FocusNode fn,
                                  VoidCallback ofs) {
                                return TextFormField(
                                  controller: ed,
                                  focusNode: fn,
                                  decoration: InputDecoration(
                                    hintText: "Pra onde?",
                                    labelText: "Destino",
                                    suffixIcon: _searchingDestiny
                                        ? const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: CircularProgressIndicator(),
                                        )
                                        : const Icon(Icons.search),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    _selectingDestiny = true;
                                    _selectingOrigin = false;
                                  },
                                  onChanged: (_) {
                                    _showAutocomplete = true;
                                  },
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        _destinyPosition == null) {
                                      return '';
                                    }
                                  },
                                );
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ]),
          Expanded(
            child: Stack(children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                    target: LatLng(-20.4630769, -45.4443985), zoom: 16),
                onCameraMove: (position) {
                  _currentPosition = position;
                },
                onCameraMoveStarted: () {
                  _gettingAddress = true;
                },
                onCameraIdle: _getAddress,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: ElevatedButton(
                      onPressed: _isInit ? null : _initTrip,
                      child: !_isInit
                          ? const Text(
                              'Partiu!',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )
                          : const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const Center(
                child: Icon(
                  Icons.add_location,
                  size: 40,
                  color: Colors.black87,
                ),
              )
            ]),
          ),
        ],
      ),
    );
  }

  void _getAddress() async {
    if (_gettingAddress) {
      if (widget.firstAddress == false) {
        if (_selectingOrigin) {
          widget.origin.text = "Carregando...";
        } else if (_selectingDestiny) {
          widget.destiny.text = "Carregando...";
        }
      }

      _destinySelectionController
          .getAddress(_currentPosition!.target.latitude,
              _currentPosition!.target.longitude)
          .then((address) {
        if (widget.firstAddress == false) {
          if (_selectingOrigin) {
            widget.origin.text = address.formattedAddress;
            _originPosition = address;
          } else if (_selectingDestiny) {
            widget.destiny.text = address.formattedAddress;
            _destinyPosition = address;
          }
        } else {
          widget.origin.text = address.formattedAddress;
          widget.firstAddress = false;
          _originPosition = address;
        }
      }).catchError((e) {
        showAlert(
            context,
            "Erro ao obter endereço no mapa!",
            "Digite o endereço aproximado para que possamos definir o ponto de origem/destino ou tente novamente mais tarde.",
            e.toString());
      });

      _gettingAddress = false;
    }
  }

  Future<Iterable<Address>> _getAutocompleteSuggestions(value) {
    final completer = Completer<Iterable<Address>>();
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      print('request');
      completer
          .complete(await _destinySelectionController.getSuggestions(value));
    });
    return completer.future;
  }

  void _initTrip() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isInit = true;
      });

      Map<String, dynamic> response = await _activityController.initActivity(
          _originPosition!, _destinyPosition!, 1);

      if (response['error'] == false) {
        if (context.mounted) {
          Navigator.pop(context, response['activity']);
        }
      } else {
        setState(() {
          _isInit = false;
        });
        FToast().init(context).showToast(
            child: MyToast(
              msg: Text(
                response['status'] == 422
                    ? response['error']
                    : 'Houve um erro ao iniciar sua corrida! Tente novamente mais tarde.',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              icon: const Icon(
                Icons.error,
                color: Colors.white,
              ),
              color: Colors.redAccent,
            ),
            gravity: ToastGravity.BOTTOM,
            toastDuration: const Duration(seconds: 5));
      }
    }
  }

  @override
  void dispose() {
    widget.origin.clear();
    widget.destiny.clear();
    _debounce?.cancel();
    super.dispose();
  }
}
