
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyToast extends StatelessWidget{

  Text? msg;
  String? title;
  Icon? icon;
  Color? color;

  MyToast({required this.msg,this.icon,this.color});

  MyToast.success({super.key, required this.title}) {
    color = Colors.greenAccent;
    icon = const Icon(Icons.check,color: Colors.white,);
    msg = Text(title!,style: const TextStyle(color: Colors.white));  
  }

  MyToast.error({super.key, required this.title}) {
    color = Colors.redAccent;
    icon = const Icon(Icons.error,color: Colors.white,);
    msg = Text(title!,style: const TextStyle(color: Colors.white,),);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: color ?? Theme.of(context).colorScheme.surface,
        ),
        child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
            icon ?? const Icon(Icons.info),
            const SizedBox(
            width: 12.0,
            ),
            Flexible(child: msg!),
        ],
        ),
    );
  }

}

toastSuccess(BuildContext context,String title){
    FToast().init(context).showToast(
        child: MyToast.success(title: title),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 4));
}

toastError(BuildContext context,String title){
  FToast().init(context).showToast(
      child: MyToast.error(title: title),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 5));
}

