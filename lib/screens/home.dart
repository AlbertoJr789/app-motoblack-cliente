
import 'package:app_motoblack_cliente/controllers/activityController.dart';
import 'package:app_motoblack_cliente/models/Activity.dart';
import 'package:app_motoblack_cliente/screens/destinySelection.dart';
import 'package:app_motoblack_cliente/widgets/trip.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {

  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  late ActivityController _controller;


  @override
  void initState() {
    super.initState();
    _controller = Provider.of<ActivityController>(context, listen: false);
    _controller.getCurrentActivity();
  }

  @override
  Widget build(BuildContext context) {
    _controller = context.watch<ActivityController>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20,
            ),
            _controller.currentActivity != null
                ? Trip() : TextField(
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      final ret = await Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (ctx) => DestinySelection()));
                      if(ret is Activity) {
                        _controller.currentActivity = ret;
                        setState(() {});
                      }

                    },
                    decoration: const InputDecoration(
                        hintText: 'Vai pra onde?',
                        prefixIcon: Icon(Icons.search),
                        iconColor: Colors.black),
                        readOnly: true,
                  ),
            
          ],
        ),
      ),
    );
  }


}
