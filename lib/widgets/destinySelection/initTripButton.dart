import 'package:app_motoblack_cliente/controllers/activityController.dart';
import 'package:app_motoblack_cliente/models/Address.dart';
import 'package:app_motoblack_cliente/widgets/assets/toast.dart';
import 'package:flutter/material.dart';

class InitTripButton extends StatefulWidget {
  const InitTripButton({super.key, required this.originPosition, required this.destinyPosition, required this.formKey});

  final Address? originPosition;
  final Address? destinyPosition;
  final GlobalKey<FormState> formKey;
  
  @override

  State<InitTripButton> createState() => _InitTripButtonState();
}

class _InitTripButtonState extends State<InitTripButton> {

  bool _isInit = false;
  final ActivityController _activityController = ActivityController();

  
  void _initTrip() async {
    if (widget.formKey.currentState!.validate()) {
      
      setState(() {
        _isInit = true;
      });

      Map<String, dynamic> response = await _activityController.initActivity(
          widget.originPosition!, widget.destinyPosition!, 1);

      if (response['error'] == false) {
        if (context.mounted) {
          Navigator.pop(context, response['activity']);

        }
      } else {

        setState(() {
          _isInit = false;
        });

        toastError(context, response['status'] == 422
          ? response['error']
          : 'Houve um erro ao iniciar sua corrida! Tente novamente mais tarde.');
              
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return  Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: ElevatedButton(
                onPressed: _initTrip,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _isInit ? CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary,) : const Text(
                        'Partiu!',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )
                    
              ),
            ),
          ),
        ));
  }
}