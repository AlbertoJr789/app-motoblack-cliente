import 'package:app_motoblack_cliente/models/Activity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class TripAgentDetails extends StatelessWidget {
  final Activity activity;
  const TripAgentDetails({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(
                            Icons.person_off_outlined,
                            color: Colors.black,
                          ),
                      imageUrl: activity.agent!.avatar ?? ''),
                ),
                Text(activity.agent!.name)
              ],
            ),
            const Expanded(child: SizedBox()),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Informações do veículo'),
                Row(
                  children: [
                    Icon(
                      activity.vehicle!.icon,
                      color: Color(int.parse(
                        '0xFF${activity.vehicle!.color.toString().replaceFirst('#', '')}',
                      )),
                      size: 70,
                    ),
                    Column(
                      children: [
                        Text(
                            '${activity.vehicle!.brand} - ${activity.vehicle!.model}'),
                        Row(
                          children: [
                            Text(
                                'Placa: ${activity.vehicle!.plate}, Cor: '),
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Container(
                                color: Color(int.parse(
                                  '0xFF${activity.vehicle!.color.toString().replaceFirst('#', '')}',
                                )),
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(
              width: 20,
            ),
          ],
        ),
       
      ],
    );
  }
}
