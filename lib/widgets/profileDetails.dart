import 'dart:ffi';
import 'dart:io';
import 'dart:ui';

import 'package:app_motoblack_cliente/controllers/profileController.dart';
import 'package:app_motoblack_cliente/util/util.dart';
import 'package:app_motoblack_cliente/widgets/assets.dart';
import 'package:app_motoblack_cliente/widgets/errorMessage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ProfileDetails extends StatefulWidget {
  const ProfileDetails({super.key});

  @override
  State<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  final _formKey = GlobalKey<FormState>();
  final ProfileController _controller = ProfileController();
  Map _profileData = {};
  bool _isSaving = false;
  bool _errorProfileData = false;

  TextEditingController _name = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _email = TextEditingController();
  late dynamic _picture;

  _saveProfile(context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      final pic = _picture is XFile ? _picture : null;
      Map<String,dynamic> ret = await _controller.saveProfile(
          _name.text, _phone.text, _email.text, pic);
      if (ret['error'] == false) {
        FToast().init(context).showToast(
            child: MyToast(
              msg: const Text(
                'Dados de perfil atualizados com sucesso.',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              icon: const Icon(
                Icons.check,
                color: Colors.white,
              ),
              color: Colors.greenAccent,
            ),
            gravity: ToastGravity.BOTTOM,
            toastDuration: const Duration(seconds: 4));
      } else {
        FToast().init(context).showToast(
            child: MyToast(
              msg: const Text(
                'Erro ao atualizar dados de perfil, tente novamente mais tarde.',
                style: TextStyle(
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
            toastDuration: const Duration(seconds: 4));
      }
      setState(() {
        _isSaving = false;
      });
    }
  }

  _fetchProfileData() async {
    print('fetch');
    _profileData = await _controller.fetchProfileData();
    if (_profileData.containsKey('error')) {
      print(_profileData);
      setState(() {
        _errorProfileData = true;
      });
    } else {
      print(_profileData);
      _name.text = _profileData['name'];
      _phone.text = _profileData['phone'] ?? '';
      _email.text = _profileData['email'] ?? '';
      _picture = _profileData['photo'];
      setState(() {
        _errorProfileData = false;
      });
    }
  }

  _takeUserPicture() async {
    _controller.takeUserPicture().then((picture) {
      if (picture is XFile) {
        setState(() {
          _picture = picture;
        });
      }
    }).catchError((error) {
      showAlert(context, "Erro ao tirar sua foto!",
          "Verifique as permissões dadas ao aplicativo.", error.toString());
    });
  }

  @override
  void initState() {
    _fetchProfileData();
    super.initState();
  }

  Widget _cameraActionButton() => Align(
      alignment: Alignment.bottomRight,
      child: FloatingActionButton.small(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: _takeUserPicture,
        child: const Icon(
          Icons.camera_alt,
          color: Colors.white,
        ),
      ));

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: _errorProfileData
          ? ErrorMessage(
              msg: 'Ocorreu um erro ao obter seus dados de perfil',
              tryAgainAction: _fetchProfileData)
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 12,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          Container(
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(64.0),
                              color: Colors.white,
                            ),
                            child: _picture is XFile
                                ? CircleAvatar(
                                    backgroundImage: FileImage(File(_picture.path)),
                                  )
                                : CachedNetworkImage(
                                    imageBuilder: (context, imageProvider) =>
                                        CircleAvatar(
                                            backgroundImage: imageProvider,
                                          ),
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) {
                                      return const Center(
                                        child: Icon(
                                          Icons.person_off_outlined,
                                          color: Colors.black,
                                          size: 36,
                                        ),
                                      );
                                    },
                                    imageUrl: _picture),
                          ),
                          Container(
                              width: 128,
                              height: 128,
                              child: _cameraActionButton())
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 12.0),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            child: const Text(
                              'Nome: ',
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Color.fromARGB(255, 216, 216, 216)),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          TextFormField(
                            controller: _name,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 12.0),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            child: const Text(
                              'Telefone: ',
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Color.fromARGB(255, 216, 216, 216)),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          TextFormField(
                            controller: _phone,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 12.0),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            child: const Text(
                              'E-mail: ',
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Color.fromARGB(255, 216, 216, 216)),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          TextFormField(
                            controller: _email,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        // width: double.infinity,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: MediaQuery.of(context).size.height * 0.07,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _saveProfile(context);
                            },
                            icon: const Icon(
                              Icons.save,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Salvar",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
