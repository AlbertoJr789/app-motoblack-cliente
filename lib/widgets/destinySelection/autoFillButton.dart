import 'package:flutter/material.dart';

class AutoFillButton extends StatefulWidget {
  const AutoFillButton({super.key, required this.onChanged});

  final Function(bool) onChanged;

  @override
  State<AutoFillButton> createState() => _AutoFillButtonState();

}

class _AutoFillButtonState extends State<AutoFillButton> {
  bool _autoFill = true;

  @override
  Widget build(BuildContext context) {
    return  Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Transform.translate(offset: const Offset(0,-100),child: Container(
              height: 60,
              decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.all(Radius.circular(8.0)),
                  color: _autoFill
                      ? Theme.of(context).colorScheme.surface
                      : Theme.of(context).colorScheme.secondary,
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.white,
                        spreadRadius: 0.5,
                        blurRadius: 0.5)
                  ]),
              // padding: const EdgeInsets.all(8.0),
              child: Tooltip(
                message: "Habilitar/Desabilitar preenchimento automático",
                child: IconButton(
                    icon: Icon(
                      _autoFill ? Icons.add_location : Icons.location_off,
                      color: _autoFill ? Colors.black : Colors.grey,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _autoFill = !_autoFill;
                      });
                      widget.onChanged(_autoFill);
                    }),

              ),
            ),) 
          ),
        );
  }
}