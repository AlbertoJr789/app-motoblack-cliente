


import 'package:app_motoblack_cliente/controllers/hereAPIController.dart';
import 'package:app_motoblack_cliente/models/Address.dart';

abstract class Geocoder {

    geocode(Address address);

    Future<Address> inverseGeocode(double latitude,double longitude);

    Future<List<Address>> autocomplete(String query);


}

class GeoCoderController {

  Geocoder? geocoder;
  //using Here API as default geocoder
  GeoCoderController({geocoder}): geocoder = geocoder ?? HereAPIController();

  // Future<Map<String,double>> geocode() async {
  //   return await geocoder!.geocode();
  // } 

  Future<Address> inverseGeocode(double latitude,double longitude) async {
    return await geocoder!.inverseGeocode(latitude, longitude);
  }

  Future<List<Address>> autocomplete(String query) async {
    return await geocoder!.autocomplete(query);
  }

}