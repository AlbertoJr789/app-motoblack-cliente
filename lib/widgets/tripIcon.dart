import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'dart:ui' as ui;

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
