
import 'package:app_motoblack_cliente/models/Activity.dart';
import 'package:app_motoblack_cliente/models/Agent.dart';
import 'package:app_motoblack_cliente/models/Vehicle.dart';
import 'package:app_motoblack_cliente/widgets/assets/infoBanner.dart';
import 'package:app_motoblack_cliente/widgets/trip/tripIcon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class ActivityDetails extends StatefulWidget {
  final Activity activity;

  ActivityDetails({super.key, required this.activity});

  @override
  State<ActivityDetails> createState() => _ActivityDetailsState();
}

class _ActivityDetailsState extends State<ActivityDetails> {
  
   final List<Marker> _markers = [];

  final List<Polyline> _polylines = [];

  final DraggableScrollableController _scrollController = DraggableScrollableController();

  _initMarkers() async {

    _markers.add(Marker(
      markerId: MarkerId('origin'),
      position: LatLng(widget.activity.origin.latitude!, widget.activity.origin.longitude!),
      infoWindow: InfoWindow(title: 'Origem'),
      icon: await createFlagBitmapFromIcon(Icon(Icons.flag,color: Theme.of(context).colorScheme.secondary,)),
    ));

    _markers.add(Marker(
      markerId: MarkerId('destiny'),
      position: LatLng(widget.activity.destiny.latitude!, widget.activity.destiny.longitude!),
      infoWindow: InfoWindow(title: 'Destino'),
      icon: await createFlagBitmapFromIcon(Icon(Icons.flag_circle,color: Theme.of(context).colorScheme.surface,)),
    ));

    _polylines.add(Polyline(
      polylineId: PolylineId('route'),
      points: [
        LatLng(widget.activity.origin.latitude!, widget.activity.origin.longitude!),
        LatLng(widget.activity.destiny.latitude!, widget.activity.destiny.longitude!),
      ],
      color: Theme.of(context).colorScheme.secondary,
      width: 5,
    ));

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initMarkers();
    });
  }


  @override
  Widget build(BuildContext context) {
    String originTime = DateFormat('dd/MM/y HH:mm').format(widget.activity.createdAt!);
    String addrOrigin = '${widget.activity.origin.street} ${widget.activity.origin.number}';

    String destinyTime =
        DateFormat('dd/MM/y HH:mm').format(widget.activity.finishedAt!);
    String addrDestiny = '${widget.activity.destiny.street} ${widget.activity.destiny.number}';

    final dynamic showEval, showObs;

    if (widget.activity.canceled!) {
      showEval =
          InfoBanner(type: 'danger', msg: 'Esta atividade foi cancelada!');
      showObs = Text(
        'Justificativa de cancelamento: ${widget.activity.cancellingReason ?? '-'}',
        style: const TextStyle(fontSize: 18),
      );
    } else {
      showEval = _evaluation(widget.activity);
      showObs = Text(
        'Observações relatadas: ${widget.activity.obs ?? '-'}',
        style: const TextStyle(fontSize: 18),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Atividade'),
      ),
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SizedBox(
            width: double.infinity,
            // height: MediaQuery.of(context).size.height * 0.3,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.activity.origin.latitude!, widget.activity.origin.longitude!),
                zoom: 12,
              ),
              markers: Set.from(_markers),
              polylines: Set.from(_polylines),
            ),
          ),
          DraggableScrollableSheet(
            controller: _scrollController,
            initialChildSize: 0.4,
            minChildSize: 0.3,
            maxChildSize: 0.7,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Center(
                           child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.black,
                                ),
                                width: 50,
                                height: 10,
                              ),
                            ),
                         ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.flag,
                                      color: Theme.of(context).colorScheme.secondary,
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
                                    Icon(
                                      Icons.timer_sharp,
                                      color: Theme.of(context).colorScheme.secondary,
                                      size: 40,
                                    ),
                                    Text(
                                      originTime,
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(fontSize: 14),
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
                                    Icon(
                                      Icons.flag_circle,
                                      color: Theme.of(context).colorScheme.surface,
                                      size: 40,
                                    ),
                                    Flexible(
                                      fit: FlexFit.loose,
                                      child: Text(
                                        addrDestiny,
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Icon(
                                      Icons.timer_sharp,
                                      color: Theme.of(context).colorScheme.surface,
                                      size: 40,
                                    ),
                                    Text(
                                      destinyTime,
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  color: Color.fromARGB(232, 221, 214, 214),
                                  thickness: 0.5,
                                ),
                                if(widget.activity.agent != null && widget.activity.vehicle != null)
                                  _agentDetails(widget.activity.agent!, widget.activity.vehicle!),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Divider(
                                  color: Color.fromARGB(232, 221, 214, 214),
                                  thickness: 0.5,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                showEval,
                                const SizedBox(
                                  height: 10,
                                ),
                                const Divider(
                                  color: Color.fromARGB(232, 221, 214, 214),
                                  thickness: 0.5,
                                ),
                                showObs
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _evaluation(activity) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Flexible(
          child: Text(
            'Sua avaliação',
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        RatingBar(
          ignoreGestures: true,
          initialRating: activity.evaluation,
          itemCount: 5,
          allowHalfRating: true,
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
    );
  }

  Widget _agentDetails(Agent agent, Vehicle vehicle) {
    int vehicleColor = int.parse(
      '0xFF${vehicle.color.toString().replaceFirst('#', '')}',
    );

    return Row(
      children: [
        const SizedBox(
          width: 10,
        ),
        Column(
          children: [
            Text(agent.typeName),
            const Text('Responsável'),
            const SizedBox(
              height: 10,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  width: 50,
                  height: 50,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.person_off_outlined,color: Colors.black,),
                  imageUrl: agent.avatar!),
            ),
            Text(agent.name),
          ],
        ),
        Container(
          height: 100,
          child: const VerticalDivider(
            color: Colors.grey,
            thickness: 1,
            width: 20,
          ),
        ),
         Expanded(
          child: Column(
            children: [
              const Text('Veículo utilizado'),
              Icon(
                vehicle.type == VehicleType.car ? Icons.directions_car : Icons.motorcycle,
                color: Color(vehicleColor),
                size: 50,
              ),
              const SizedBox(
                height: 10,
              ),
              Text('${vehicle.model} - Placa ${vehicle.plate}'),
            ],
          ),
        ),
      ],
    );
  }
}
