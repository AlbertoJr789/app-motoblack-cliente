import 'dart:io';
import 'dart:ui';

import 'package:app_motoblack_cliente/controllers/profileController.dart';
import 'package:app_motoblack_cliente/util/util.dart';
import 'package:app_motoblack_cliente/widgets/assets.dart';
import 'package:app_motoblack_cliente/widgets/errorMessage.dart';
import 'package:app_motoblack_cliente/widgets/phoneInput.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
      Map<String, dynamic> ret = await _controller.saveProfile(
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
              msg: Text(
                ret['status'] == 422
                    ? ret['error']
                    : 'Erro ao atualizar dados de perfil, tente novamente mais tarde.',
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
      setState(() {
        _isSaving = false;
      });
    }
  }

  _fetchProfileData() async {
    _profileData = await _controller.fetchProfileData();
    if (_profileData.containsKey('error')) {
      setState(() {
        _errorProfileData = true;
      });
    } else {
      _name.text = _profileData['name'];
      _phone.text = _profileData['phone'] ?? '';
      _email.text = _profileData['email'] ?? '';
      _picture = _profileData['photo'];
      setState(() {
        _errorProfileData = false;
      });
    }
  }

  _takeUserPicture(ImageSource source) async {
    _controller.takeUserPicture(source).then((picture) {
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
      child: PopupMenuButton(
        icon: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            color: Theme.of(context).colorScheme.primary,
            boxShadow: [BoxShadow(color: Colors.white,spreadRadius: 0.5,blurRadius: 0.5)]
          ),
          padding: const EdgeInsets.all(8.0),
          child: const Icon(
            Icons.camera_alt,
            color: Colors.white,
          ),
        ),
        tooltip: "Alterar Foto",
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: ImageSource.camera,
            child: Text('Tirar Foto'),
          ),
          const PopupMenuItem(
            value: ImageSource.gallery,
            child: Text('Obter da Galeria'),
          ),
        ],
        onSelected: (value){
          _takeUserPicture(value);
        },
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
                                    backgroundImage:
                                        FileImage(File(_picture.path)),
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
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Nome não pode estar vazio';
                              return null;
                            },
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
                          PhoneInput(controller: _phone)
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
                            onPressed: !_isSaving
                                ? () {
                                    _saveProfile(context);
                                  }
                                : null,
                            icon: const Icon(
                              Icons.save,
                              color: Colors.white,
                            ),
                            label: !_isSaving
                                ? const Text(
                                    'Salvar',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
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
                  ],
                ),
              ),
            ),
    );
  }
}
