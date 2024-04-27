import 'package:app_motoblack_cliente/models/Activity.dart';
import 'package:app_motoblack_cliente/screens/activityDetails.dart';
import 'package:app_motoblack_cliente/widgets/textBadge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivityCard extends StatelessWidget {

  final Activity activity;

  const ActivityCard({super.key,required this.activity});

  @override
  Widget build(BuildContext context) {
    String title = '${activity.typeName} ${DateFormat('d/M/y H:m').format(activity.createdAt)}';
    String addr = '${activity.origin.street} ${activity.origin.number}';
    print('build card');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: const Color.fromARGB(255, 197, 179, 88),
        onTap: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ActivityDetails()));
        },
        child: Card(
          shadowColor: const Color.fromARGB(255, 197, 179, 88),
          color: const Color.fromARGB(243, 221, 221, 219),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextBadge(
                          msg: Text(
                        title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Row(
                          children: [
                            Flexible(child: Text(addr)),
                            // Expanded(child: const SizedBox()),
                            // Text(
                            //   'RS 10,00',
                            //   style: TextStyle(fontWeight: FontWeight.bold),
                            // ),
                          ],
                        ),
                      )
                    ]),
              ),
              // Text(
              //   'Mototaxista Responsável',
              //   textAlign: TextAlign.center,
              // ),
              const Expanded(child: SizedBox()),
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color.fromARGB(255, 32, 39, 44),
                backgroundImage: Image.network(activity.agent.avatar!).image,
              ),
              const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.arrow_right,
                    color: Colors.black,
                  ),
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }
}
