import 'package:app_motoblack_cliente/models/Activity.dart';
import 'package:app_motoblack_cliente/widgets/assets/photoWithRate.dart';
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
                PhotoWithRate(avatar: activity.agent!.avatar, rate: activity.agent!.rate,size: 75),
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
