
import 'package:app_motoblack_cliente/controllers/activityController.dart';
import 'package:app_motoblack_cliente/widgets/FloatingLoader.dart';
import 'package:app_motoblack_cliente/widgets/activityCard.dart';
import 'package:app_motoblack_cliente/widgets/errorMessage.dart';
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
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          controller.hasMore) {
        loadActivities();
      }
    });
    controller = Provider.of<ActivityController>(context, listen: false);
    loadActivities();
  }

  loadActivities() async {
    _isLoading.value = true;
    await controller.getActivities();
    _isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    controller = context.watch<ActivityController>();
    dynamic message;

    if(controller.error.isNotEmpty){
        message = ErrorMessage(msg: 'Houve um erro ao tentar obter suas atividades', tryAgainAction: controller.getActivities);
    }else{
      if(controller.activities.isEmpty){
        message = ErrorMessage(msg: 'Você ainda não realizou nenhuma atividade.\nFaça sua primeira corrida!',icon: const Icon(Icons.notes,size: 128,color: Colors.white60,),);
      }else{
        message = null;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atividades mais recentes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadActivities,
          ),
        ]
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
        child: message ?? Stack(
          children: [
            ListView.builder(
                controller: _scrollController,
                itemCount: controller.activities.length,
                itemBuilder: (ctx, index) =>
                    ActivityCard(activity: controller.activities[index])),
            FloatingLoader(active: _isLoading)
          ],
        ),
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
