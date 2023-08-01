import 'dart:async';

import 'package:app_motoblack_cliente/screens/destinySelection.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatefulWidget {

  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin,AutomaticKeepAliveClientMixin<Home> {

  @override
  bool get wantKeepAlive => true;

  bool _driveMode = false;
  late var _driveRes;
  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;
  late Timer _timer;
  late String _time;
  final Stopwatch _stopwatch = Stopwatch();


  // @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _topAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.topLeft, end: Alignment.topRight),
          weight: 1),
      TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.topRight, end: Alignment.bottomRight),
          weight: 1),
      TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.bottomRight, end: Alignment.bottomLeft),
          weight: 1),
      TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.bottomLeft, end: Alignment.topLeft),
          weight: 1),
    ]).animate(_controller);

    _bottomAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.bottomRight, end: Alignment.bottomLeft),
          weight: 1),
      TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.bottomLeft, end: Alignment.topLeft),
          weight: 1),
      TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.topLeft, end: Alignment.topRight),
          weight: 1),
      TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.topRight, end: Alignment.bottomRight),
          weight: 1),
    ]).animate(_controller);
    _controller.repeat();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if(_stopwatch.elapsed.inHours > 0){
        setState(() {
          _time = '${_stopwatch.elapsed.inHours.toString().padLeft(2, '0')}:${_stopwatch.elapsed.inMinutes.toString().padLeft(2, '0')}:${(_stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
        });
      }else{
        setState(() {
          _time = '${_stopwatch.elapsed.inMinutes.toString().padLeft(2, '0')}:${(_stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
        });
      }
    });

  }

  void _endRideDialog(){
      showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tem certeza que deseja cancelar a corrida ?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _stopwatch.reset();
                _stopwatch.stop();
                _driveMode = false;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Sim'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); 
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Material(
              child: _driveMode
                  ? AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        _stopwatch.start();
                        return Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: const [
                                  Color.fromARGB(255, 197, 179, 88),
                                  Color.fromARGB(255, 238, 205, 39),
                                ],
                                begin: _topAlignmentAnimation.value,
                                end: _bottomAlignmentAnimation.value),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Corrida em Andamento  $_time",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _endRideDialog,
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Cancelar",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(Colors
                                            .red), // Set the background color of the icon
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : TextField(
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        _driveRes = await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (ctx) => DestinySelection()));
                        if (_driveRes != null) {
                          setState(() {
                            _driveMode = true;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                          hintText: 'Vai pra onde?',
                          prefixIcon: Icon(Icons.search),
                          iconColor: Colors.black),
                    ),
            ),
            const SizedBox(
              height: 8.0,
            ),
            Expanded(
              child: _driveMode
                  ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                          target: LatLng(_driveRes['origin']['lat'],
                              _driveRes['origin']['lon']),
                          zoom: 16),
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
