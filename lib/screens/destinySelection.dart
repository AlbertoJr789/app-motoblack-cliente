import 'package:app_motoblack_cliente/controllers/activityController.dart';
import 'package:app_motoblack_cliente/controllers/destinySelectionController.dart';
import 'package:app_motoblack_cliente/models/Activity.dart';
import 'package:app_motoblack_cliente/models/Address.dart';
import 'package:app_motoblack_cliente/widgets/assets/toast.dart';
import 'package:app_motoblack_cliente/widgets/destinySelection/addressAutoComplete.dart';
import 'package:app_motoblack_cliente/widgets/destinySelection/autoFillButton.dart';
import 'package:app_motoblack_cliente/widgets/destinySelection/initTripButton.dart';
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

  //map address flags
  bool _gettingAddress = false;
  bool _autoFill = true;

  
  bool _selectingOrigin = false;
  bool _selectingDestiny = true;

  CameraPosition? _currentPosition;
  GoogleMapController? _mapController;

  Address? _originPosition;
  Address? _destinyPosition;

  final DestinySelectionController _destinySelectionController =
      DestinySelectionController();

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
                        AddressAutoComplete(textController: widget.origin, focusNode: widget.originfocusNode, formFieldKey: widget.originKey, mapController: _mapController),
                        const SizedBox(
                          height: 10,
                        ),
                        AddressAutoComplete(textController: widget.destiny, focusNode: widget.destinyfocusNode, formFieldKey: widget.destinyKey, mapController: _mapController),
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
              AutoFillButton(onChanged: (value) {
                _autoFill = value;
              }),
              InitTripButton(originPosition: _originPosition, destinyPosition: _destinyPosition, formKey: _formKey),
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



  @override
  void dispose() {
    widget.origin.clear();
    widget.destiny.clear();
    widget.originfocusNode.dispose();
    widget.destinyfocusNode.dispose();
    super.dispose();
  }
}
