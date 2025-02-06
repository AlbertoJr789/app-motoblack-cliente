import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class InfoBanner extends StatelessWidget {
  final String msg;
  final String? type;

  InfoBanner({required this.msg, this.type});

  @override
  Widget build(BuildContext context) {
    final color = {};

    switch (type) {
      case 'danger':
        {
          color['border'] = Color.fromARGB(255, 228, 96, 86);
          color['background'] = Color.fromARGB(255, 228, 155, 155);
          color['text'] = Colors.white;
          break;
        }
      default:
        {
          color['border'] = Theme.of(context).colorScheme.surface;
          color['background'] = Colors.amber.shade100;
          color['text'] = Theme.of(context).textTheme.bodySmall?.color;
        }
    }

    return DottedBorder(
      color: color['border'],
      borderType: BorderType.RRect,
      radius: Radius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: color['background'],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info,color: color['border'],),
            const SizedBox(
              width: 12.0,
            ),
            Text(
              msg,
              style: TextStyle(
                  color: color['text'],
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
