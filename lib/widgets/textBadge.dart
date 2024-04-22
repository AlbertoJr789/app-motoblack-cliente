
import 'package:flutter/material.dart';


class TextBadge extends StatelessWidget{

  final Text msg;
  final Icon? icon;
  final Color? color;

  TextBadge({required this.msg,this.icon,this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: color ?? Theme.of(context).colorScheme.surface,
        ),
        child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
            Flexible(child: msg),
          ],
        ),
    );
  }

}
