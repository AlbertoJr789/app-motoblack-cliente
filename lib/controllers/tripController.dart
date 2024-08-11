
import 'package:app_motoblack_cliente/controllers/apiClient.dart';
import 'package:app_motoblack_cliente/models/Activity.dart';
import 'package:app_motoblack_cliente/models/Agent.dart';
import 'package:dio/dio.dart';

class TripController {

  int tries = 0;
  static final ApiClient apiClient = ApiClient.instance;

  /// 
  ///  Gets most suited agent for the trip
  Future<Agent?> drawAgent(Activity trip) async {
      try {
      Response response = await apiClient.dio.get(
        '/api/drawAgent',
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          headers: {
            'accept': 'application/json',
          },
        ),
        queryParameters: {
          'latitude': trip.origin.latitude,
          'longitude': trip.origin.longitude,
          'tripType': trip.type.index
        },
      );
      if (response.data.containsKey('data')) {
        return Agent.fromJson(response.data['data']);
      } else {
        tries++;
        return null;
      }
    } on DioException catch (e) {
      tries++;
      return null;
    } catch (e) {
      tries++;
      return null;
    }
  }

  


}