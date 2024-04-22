import 'dart:io';

import 'package:app_motoblack_cliente/controllers/activityController.dart';
import 'package:app_motoblack_cliente/screens/activityDetails.dart';
import 'package:app_motoblack_cliente/widgets/FloatingLoader.dart';
import 'package:app_motoblack_cliente/widgets/activityCard.dart';
import 'package:app_motoblack_cliente/widgets/textBadge.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Activities extends StatefulWidget {
  const Activities({super.key});

  @override
  State<Activities> createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> {
  final ActivityController _controller = ActivityController();
  final ScrollController _scrollController = ScrollController();
  final _isLoading = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
  
    _isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Atividades mais recentes'),
      ),
      body: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            itemCount: 10,
            itemBuilder: (ctx, index) => ActivityCard()
          ),
          FloatingLoader(active: _isLoading)
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _isLoading.dispose();
    super.dispose();
  }
}
