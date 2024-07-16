
import 'package:app_motoblack_cliente/controllers/geoCoderController.dart';
import 'package:app_motoblack_cliente/models/Address.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class GoogleAPIController implements Geocoder {

  static String _apiKey = 'AIzaSyCgo47TDRIpqJ2ZDmMcGWwkxI6oejOju0U';

  @override
   geocode(Address address) async {
    final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=&key=$_apiKey');

    final response = await http.get(url);

  }

  @override
  Future<Address> inverseGeocode(double latitude,double longitude) async {
    final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latitude},${longitude}&key=$_apiKey');

      final response = await http.get(url);
      final data = json.decode(response.body);

      Address address = Address(latitude: latitude,longitude: longitude);
      data['results'][0]['address_components'].forEach((component){
        String data = component['short_name'];
        if(component['types'].contains('route')){
          address.street = data;
        } else if(component['types'].contains('street_number')){
          address.number = data; 
        }else if(component['types'].contains('neighborhood')){
          address.neighborhood = data;
        }else if(component['types'].contains('postal_code')){
          address.zipCode = data;
        }else if(component['types'].contains('country')){
          address.country = data;
        }else if(component['types'].contains('administrative_area_level_1')){
          address.state = data;
        }else if(component['types'].contains('administrative_area_level_2')){
          address.city = data;
        }
        
      });
    return address;
  }

  @override
  Future<List<Address>> autocomplete(String query) async {
    final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=&key=$_apiKey');

    final response = await http.get(url);

      List<Address> addresses = [];
      return addresses;
  }

}