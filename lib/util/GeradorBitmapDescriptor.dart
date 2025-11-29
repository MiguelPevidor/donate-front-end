import 'dart:io';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart'; // Necessário para IconData e Colors
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeradorBitmapDescriptor {

  /// Gera um BitmapDescriptor a partir de um IconData (ex: Icons.location_on)
  static Future<BitmapDescriptor> gerarIcone(IconData icon, Color color, {double size = 100.0}) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: size,
        fontFamily: icon.fontFamily,
        color: color,
      ),
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset.zero);

    final ui.Image image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final ByteData? data = await image.toByteData(format: ui.ImageByteFormat.png);
    
    if (data == null) {
      return BitmapDescriptor.defaultMarker;
    }
    
    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  static Future<BitmapDescriptor> gerarBitMapDescriptorFromAsset(String path, int width) async{
    final Uint8List markerImageBytes = await getBytesFromAsset(path, width);
    return BitmapDescriptor.fromBytes(markerImageBytes);
  }

  static Future<BitmapDescriptor> gerarBitMapDescriptorFromFile(File file, int width) async{
    final Uint8List markerImageBytes = await file.readAsBytes();
    final ui.Codec markerImageCodec = await ui.instantiateImageCodec(
      markerImageBytes,
      targetWidth: width,
    );

    final ui.FrameInfo frameInfo = await markerImageCodec.getNextFrame();

    final ByteData? byteData = await frameInfo.image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    final Uint8List resizedMarkerImageBytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(resizedMarkerImageBytes);
  }
}