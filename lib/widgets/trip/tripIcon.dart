import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> getMarkerImageFromUrl(
  String url, {
  int? targetWidth,
}) async {
  final File markerImageFile = await DefaultCacheManager().getSingleFile(url);

  Uint8List markerImageBytes = await markerImageFile.readAsBytes();

  if (targetWidth != null) {
    markerImageBytes = await _resizeImageBytes(
      markerImageBytes,
      targetWidth,
    );
  }

  return BitmapDescriptor.fromBytes(markerImageBytes);
}

Future<Uint8List> _resizeImageBytes(
  Uint8List imageBytes,
  int targetWidth,
) async {
  final ui.Codec imageCodec = await ui.instantiateImageCodec(
    imageBytes,
    targetWidth: targetWidth,
  );

  final ui.FrameInfo frameInfo = await imageCodec.getNextFrame();

  final data = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);

  return data!.buffer.asUint8List();
}

Future<BitmapDescriptor> createFlagBitmapFromIcon(Icon icon) async {
  final pictureRecorder = ui.PictureRecorder();
  final canvas = Canvas(pictureRecorder);
  final paint = Paint().color = Colors.black; // Or your desired color
  
  // Create a paragraph builder for the icon
  final textPainter = TextPainter(textDirection: TextDirection.ltr);
  textPainter.text = TextSpan(
    text: String.fromCharCode(icon.icon!.codePoint),
    style: TextStyle(
      fontSize: 96,
      fontFamily: icon.icon!.fontFamily,
      color: icon.color,
    ),
  );
  
  textPainter.layout();
  textPainter.paint(canvas, Offset.zero);
  
  final picture = pictureRecorder.endRecording();
  final image = await picture.toImage(96, 96);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  
  return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
}