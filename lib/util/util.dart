
//generic function that shows a dialog
import 'package:flutter/material.dart';

void showAlert(BuildContext context,String message, {String? sol,String? error}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ops!'),
        content: Text("${message}\n\nMotivo do erro: ${error}\n\n${sol}"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }