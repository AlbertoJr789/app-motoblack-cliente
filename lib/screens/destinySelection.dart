import 'package:flutter/material.dart';

class DestinySelection extends StatefulWidget {
  const DestinySelection({super.key});

  @override
  State<DestinySelection> createState() => _DestinySelectionState();
}

class _DestinySelectionState extends State<DestinySelection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleção de corrida'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(children: [
           Material(
            child: Column(
              children: [
                TextField(),
                TextField(),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
