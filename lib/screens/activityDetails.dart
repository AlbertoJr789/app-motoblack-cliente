import 'package:flutter/material.dart';

class ActivityDetails extends StatelessWidget {
  const ActivityDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Atividade'),
      ),
      body: Center(
        child: Text('Detalhes da atividade'),
      ),
    );
  }
}
