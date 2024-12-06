import 'package:app_motoblack_cliente/controllers/activityController.dart';
import 'package:app_motoblack_cliente/controllers/destinySelectionController.dart';
import 'package:app_motoblack_cliente/models/Activity.dart';
import 'package:app_motoblack_cliente/models/Address.dart';
import 'package:app_motoblack_cliente/widgets/assets.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../util/util.dart';
import 'dart:async';

class DestinySelection extends StatefulWidget {
  DestinySelection({super.key});

  final TextEditingController origin = TextEditingController();
  final TextEditingController destiny = TextEditingController();
  
  //vallidation control
  final originKey = GlobalKey<FormFieldState<String>>();
  final destinyKey = GlobalKey<FormFieldState<String>>();

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
  bool _autoFill = true;
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

  void _initTrip() async {
    if (_formKey.currentState!.validate()) {
     
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
    widget.originfocusNode.addListener(() {
      setState(() {});
    });
    widget.destinyfocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar corrida'),
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
                        LayoutBuilder(builder: (context, constraints) {
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
                              final suggestions =
                                  await _getAutocompleteSuggestions(
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
                                    child: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.2,
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
                                                  _gettingAddress = false;
                                                  onSelected(option);
                                                  widget.originKey.currentState!.validate();
                                                  _destinySelectionController.storeSuggestion(option);
                                                  _mapController?.animateCamera(
                                                    CameraUpdate
                                                        .newCameraPosition(
                                                      CameraPosition(
                                                        target: LatLng(
                                                            option.latitude!,
                                                            option.longitude!),
                                                        zoom: 16,
                                                      ),
                                                    ),
                                                  );
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
                                key: widget.originKey,
                                decoration: InputDecoration(
                                  hintText: "De onde ?",
                                  labelText: "Origem",
                                  suffixIcon: _searchingOrigin
                                      ? const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: CircularProgressIndicator(),
                                        )
                                      : InkWell(
                                          onTap: fn.hasFocus
                                              ? () {
                                                  _originPosition = null;
                                                  widget.origin.text = '';
                                                }
                                              : null,
                                          child: fn.hasFocus
                                              ? const Icon(Icons.close_rounded)
                                              : const Icon(Icons.search),
                                        ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  _selectingDestiny = false;
                                  _selectingOrigin = true;
                                  if (_originPosition != null) {
                                    _gettingAddress = false;
                                    _mapController?.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                          target: LatLng(
                                              _originPosition!.latitude!,
                                              _originPosition!.longitude!),
                                          zoom: 16,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                onChanged: (_) {
                                  _showAutocomplete = true;
                                },
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      _originPosition == null) {
                                    return 'Endereço inválido!';
                                  }
                                  return null;
                                },
                              );
                            },
                          );
                        }),
                        const SizedBox(
                          height: 10,
                        ),
                        LayoutBuilder(builder: (context, constraints) {
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
                              final suggestions =
                                  await _getAutocompleteSuggestions(
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
                                    child: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.2,
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
                                                  _gettingAddress = false;
                                                  onSelected(option);
                                                  _destinySelectionController.storeSuggestion(option);
                                                  widget.destinyKey.currentState!.validate();
                                                  _mapController?.animateCamera(
                                                    CameraUpdate
                                                        .newCameraPosition(
                                                      CameraPosition(
                                                        target: LatLng(
                                                            option.latitude!,
                                                            option.longitude!),
                                                        zoom: 16,
                                                      ),
                                                    ),
                                                  );
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
                                key: widget.destinyKey,
                                decoration: InputDecoration(
                                  hintText: "Pra onde?", 
                                  labelText: "Destino",
                                  suffixIcon: _searchingDestiny
                                      ? const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: CircularProgressIndicator(),
                                        )
                                      : InkWell(
                                          onTap: fn.hasFocus
                                              ? () {
                                                  _destinyPosition = null;
                                                  widget.destiny.text = '';
                                                }
                                              : null,
                                          child: fn.hasFocus
                                              ? const Icon(Icons.close_rounded)
                                              : const Icon(Icons.search)),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  _selectingDestiny = true;
                                  _selectingOrigin = false;
                                  if (_destinyPosition != null) {
                                    _gettingAddress = false;
                                    _mapController?.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                          target: LatLng(
                                              _destinyPosition!.latitude!,
                                              _destinyPosition!.longitude!),
                                          zoom: 16,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                onChanged: (_) {
                                  _showAutocomplete = true;
                                },
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      _destinyPosition == null) {
                                    return 'Endereço inválido!';
                                  }
                                  return null;
                                },
                              );
                            },
                          );
                        }),
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
                // onCameraMoveStarted: () {
                // _gettingAddress = true;
                // },
                onCameraIdle: _getAddress,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Transform.translate(offset: const Offset(0,-100),child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8.0)),
                        color: _autoFill
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.white,
                              spreadRadius: 0.5,
                              blurRadius: 0.5)
                        ]),
                    // padding: const EdgeInsets.all(8.0),
                    child: Tooltip(
                      message: "Habilitar/Desabilitar preenchimento automático",
                      child: IconButton(
                          icon: Icon(
                            _autoFill ? Icons.add_location : Icons.location_off,
                            color: _autoFill ? Colors.black : Colors.grey,
                            size: 24,
                          ),
                          onPressed: () {
                            setState(() {
                              _autoFill = !_autoFill;
                            });
                          }),
                    ),
                  ),) 
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: ElevatedButton(
                      onPressed: _initTrip,
                      child: const Text(
                              'Partiu!',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )
                         
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
    if (_gettingAddress && _autoFill) {
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
            widget.originKey.currentState!.validate();                   
          } else if (_selectingDestiny) {
            widget.destiny.text = address.formattedAddress;
            _destinyPosition = address;
            widget.destinyKey.currentState!.validate();           
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
    }
    _gettingAddress = true;
  }

  Future<Iterable<Address>> _getAutocompleteSuggestions(value) {
    final completer = Completer<Iterable<Address>>();
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      completer
          .complete(await _destinySelectionController.getSuggestions(value));
    });
    return completer.future;
  }

  @override
  void dispose() {
    widget.origin.clear();
    widget.destiny.clear();
    widget.originfocusNode.dispose();
    widget.destinyfocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
