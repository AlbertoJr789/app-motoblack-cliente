import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FloatingLoader extends StatefulWidget {
  final ValueListenable<bool> active;

  FloatingLoader({super.key, required this.active});

  @override
  State<FloatingLoader> createState() => _FloatingLoaderState();
}

class _FloatingLoaderState extends State<FloatingLoader> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.active,
        builder: (context, bool isLoading, _) {
          return isLoading
              ?  Positioned(
                  left: (MediaQuery.of(context).size.width/2)-20,
                  bottom: 24,
                  child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircleAvatar(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2,),
                    ),
                  ),
                ))
              : Container();
        });
  }
}
