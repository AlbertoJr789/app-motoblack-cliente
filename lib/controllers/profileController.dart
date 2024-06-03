
import 'package:app_motoblack_cliente/controllers/apiClient.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileController {

  static final ApiClient apiClient = ApiClient.instance;

  Future<Map<String,dynamic>> fetchProfileData() async {
    try {
      String? token = await apiClient.token;
      Response response = await apiClient.dio.get(
        '/api/profileData',
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {
            'accept': 'application/json',
            'Authorization': "Bearer $token"
          },
        ),
      );
      if (response.data['success']) {
        return response.data['data']['result'];
      } else {
        return {'error': response.data['message']};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String,dynamic>> saveProfile(String name,String phone,String email,XFile? picture) async {
    try {
      String? token = await apiClient.token;
      FormData data = FormData.fromMap({
        'name': name,
        'phone': phone,
        'email': email,
        'photo': picture != null ? await MultipartFile.fromFile(picture.path) : null
      });
      Response response = await apiClient.dio.post(
        '/api/updateProfile',
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          headers: {
            'accept': 'application/json',
            'Authorization': "Bearer $token"
          },
        ),
        data: data,
      );
      print(response);
      if (response.data['success']) {
        return {"error": false};
      } else {
        return {"error": response.data['message']};
      }
    } catch (e) {
      print(e.toString());
      return {"error": e.toString()};
    }
  }

  Future<dynamic> takeUserPicture() async {
      try {

          Map<Permission,PermissionStatus> statuses = await [
            Permission.camera,
            Permission.photos
          ].request();
          String erro = '';
          if(statuses[Permission.camera] != PermissionStatus.granted){
            erro += 'O acesso a câmera foi bloqueado!\n';
          }

          if(statuses[Permission.photos] != PermissionStatus.granted){
            erro += 'O acesso a galeria foi bloqueado!\n';
          }

          if(erro.isNotEmpty) throw erro;
          return await ImagePicker().pickImage(source: ImageSource.camera);
      } catch (e) {
        print('cai catch');
        return Future.error(e.toString());
      }
  }


}
