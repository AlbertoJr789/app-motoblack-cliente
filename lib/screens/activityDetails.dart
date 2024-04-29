import 'package:app_motoblack_cliente/models/Activity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class ActivityDetails extends StatelessWidget {
  final Activity activity;

  const ActivityDetails({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    String originTime = DateFormat('dd/MM/y HH:mm').format(activity.createdAt);
    String addrOrigin = '${activity.origin.street} ${activity.origin.number}';

    String destinyTime =
        DateFormat('dd/MM/y HH:mm').format(activity.finishedAt!);
    String addrDestiny = '${activity.origin.street} ${activity.origin.number}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Atividade'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.3,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(-20.461858529051117, -45.43592934890276),
                zoom: 12,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              color: Color.fromARGB(255, 245, 245, 245),
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.not_started,
                            color: Colors.black,
                            size: 40,
                          ),
                          Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              addrOrigin,
                              textAlign: TextAlign.start,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Icon(
                            Icons.timer_sharp,
                            color: Colors.black,
                            size: 40,
                          ),
                          Text(
                            originTime,
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 18.0),
                        child: SizedBox(
                          height: 30,
                          width: 3,
                          child: Container(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.flag_circle,
                            color: Colors.black,
                            size: 40,
                          ),
                          Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              addrDestiny,
                              textAlign: TextAlign.start,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Icon(
                            Icons.timer_sharp,
                            color: Colors.black,
                            size: 40,
                          ),
                          Text(
                            destinyTime,
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const Divider(
                        color: Color.fromARGB(232, 221, 214, 214),
                        thickness: 0.5,
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                Image.network(activity.agent.avatar!).image,
                            backgroundColor: Colors.blue,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Text(
                              'Você avaliou ${activity.agent.name}',
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          RatingBar(
                            ignoreGestures: true,
                            initialRating:
                                double.parse(activity.evaluation.toString()),
                            itemCount: 5,
                            ratingWidget: RatingWidget(
                                full: const Icon(Icons.star, color: Colors.amber),
                                half: const Icon(Icons.star_half, color: Colors.amber),
                                empty: const Icon(
                                  Icons.star_outline_outlined,
                                  color: Color.fromARGB(255, 209, 203, 203),
                                )),
                            onRatingUpdate: (rate) {},
                          )
                          // EvaluationStar(activity.evaluation),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      const Divider(
                        color: Color.fromARGB(232, 221, 214, 214),
                        thickness: 0.5,
                      ),
                      Text(
                        'Observações relatadas: ${activity.obs ?? '-'}',
                        style: TextStyle(fontSize: 18),
                      ),
                      
                    ],
                  ),
                ),
              ),
            ),
          ),
        
        
        ],
      ),
    );
  }
}
