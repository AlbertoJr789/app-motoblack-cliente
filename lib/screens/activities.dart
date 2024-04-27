import 'dart:io';

import 'package:app_motoblack_cliente/controllers/activityController.dart';
import 'package:app_motoblack_cliente/models/Activity.dart';
import 'package:app_motoblack_cliente/screens/activityDetails.dart';
import 'package:app_motoblack_cliente/widgets/FloatingLoader.dart';
import 'package:app_motoblack_cliente/widgets/activityCard.dart';
import 'package:app_motoblack_cliente/widgets/textBadge.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Activities extends StatefulWidget {
  const Activities({super.key});

  @override
  State<Activities> createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> {
  late ActivityController controller;
  final ScrollController _scrollController = ScrollController();
  final _isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() { 
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent && controller.hasMore){
        loadActivities();
      }
    });
    controller = Provider.of<ActivityController>(context,listen: false);
    loadActivities();
  }

  loadActivities() async {
    print('loadActivities');
    _isLoading.value = true;
    await controller.getActivities();
    _isLoading.value = false;
    print('loadedActivities');
  }

  @override
  Widget build(BuildContext context) {
    controller = context.watch<ActivityController>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Atividades mais recentes'),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                itemCount: controller.activities.length,
                itemBuilder: (ctx, index) => ActivityCard(activity: controller.activities[index])
              ),
              FloatingLoader(active: _isLoading)
            ],
          ),
          const SizedBox(height: 20,)
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
