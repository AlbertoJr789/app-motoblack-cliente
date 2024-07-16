
import 'dart:async';
import 'package:app_motoblack_cliente/controllers/geoCoderController.dart';
import 'package:app_motoblack_cliente/models/Address.dart';
import 'package:geolocator/geolocator.dart';

class DestinySelectionController {

  List<Address> _suggestions = [
      // Address(street: "Rua A",number: "20",state: "MG",city: "Formiga"),
      // Address(street: "Rua B",number: "20",state: "MG",city: "Formiga"),
      // Address(street: "Rua C",number: "20",state: "MG",city: "Formiga")
  ];

  Future<Position> getUserLocation() async {
    try {

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
          throw 'Seu serviço de localização está desativado! Reative-o nas configurações do seu dispositivo.';
      }

      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          throw 'Permissão negada! Precisamos da sua permissão para obter sua localização automaticamente!';
      }

      Position position = await Geolocator.getCurrentPosition();
      return position;
    } catch (e) {
      return Future.error(e.toString());
    }
  }
    
  Future<Address> getAddress(double latitude, double longitude) async {
    try {
          
      Address address = await GeoCoderController().inverseGeocode(latitude, longitude);
      
      return address;
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<Iterable<Address>> getSuggestions(String query) async {
     try {

      Iterable<Address> addresses = [];
      if(_suggestions.isNotEmpty){
          addresses = _suggestions.where((Address element) => 
          element.formattedAddress.trim().toLowerCase().contains(query.trim().toLowerCase())
          ).toList();
      }

      if(addresses.isEmpty) {
        addresses = await GeoCoderController().autocomplete(query);
      }
      
      Set<Address> unique = {..._suggestions,...addresses};
      _suggestions = unique.toList();
      return addresses;
    } catch (e) {
      return Future.error(e.toString());
    }
  }


}