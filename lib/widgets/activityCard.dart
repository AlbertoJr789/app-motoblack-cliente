import 'package:app_motoblack_cliente/models/Activity.dart';
import 'package:app_motoblack_cliente/screens/activityDetails.dart';
import 'package:app_motoblack_cliente/widgets/textBadge.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;

  const ActivityCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    String title =
        '${activity.typeName} ${DateFormat('dd/MM/y H:m').format(activity.createdAt)}';
    String addr = '${activity.origin.street} ${activity.origin.number}';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: const Color.fromARGB(255, 197, 179, 88),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ActivityDetails(activity: activity)));
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
              const Expanded(child: SizedBox()),
              if(activity.agent != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) {
                          return const Icon(Icons.person_off_outlined);
                      },
                      imageUrl: activity.agent!.avatar!),
                ),
              // CircleAvatar(
              //   radius: 30,
              //   backgroundColor: const Color.fromARGB(255, 32, 39, 44),
              //   backgroundImage: Image.network().image,
              // ),
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
