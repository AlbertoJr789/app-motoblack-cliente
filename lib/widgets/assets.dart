
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class MyToast extends StatelessWidget{

  final Text msg;
  final Icon? icon;
  final Color? color;

  MyToast({required this.msg,this.icon,this.color});

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
            Flexible(child: msg),
        ],
        ),
    );
  }

}
