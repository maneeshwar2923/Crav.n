import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../theme/colors.dart';

class MarkerGenerator {
  static Future<BitmapDescriptor> createCustomMarkerBitmap(
    String? imageUrl,
    String? priceLabel, {
    Size size = const Size(150, 150),
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = cravnPrimary;
    final Paint whitePaint = Paint()..color = Colors.white;

    final double radius = size.width / 2;
    final double borderWidth = 8.0;

    // 1. Draw Green Border Circle
    canvas.drawCircle(Offset(radius, radius), radius, paint);

    // 2. Draw White Inner Circle
    canvas.drawCircle(Offset(radius, radius), radius - borderWidth, whitePaint);

    // 3. Draw Image (if available)
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final ui.Image image = await _loadImage(imageUrl);
        
        // Circular Clipping path
        final Path clipPath = Path()
          ..addOval(Rect.fromCircle(
            center: Offset(radius, radius),
            radius: radius - borderWidth - 4.0, // 4px padding
          ));
        
        canvas.save();
        canvas.clipPath(clipPath);

        // Scale image to cover
        final double scale = (radius * 2) / image.width; // Simple scale width
        final double imageSize = radius * 2;
        
        // Draw image centered and covering
        paint_image(
          canvas: canvas,
          rect: Rect.fromLTWH(0, 0, size.width, size.height),
          image: image,
          fit: BoxFit.cover,
        );
        
        canvas.restore();
      } catch (e) {
        // Fallback icon if image fails
        _drawFallbackIcon(canvas, radius, borderWidth);
      }
    } else {
      _drawFallbackIcon(canvas, radius, borderWidth);
    }
    
    // 3.5 Draw Price Badge (if price provided)
    if (priceLabel != null && priceLabel.isNotEmpty) {
       _drawPriceBadge(canvas, size, priceLabel);
    }

    // 4. Convert to BitmapDescriptor
    final ui.Image markerAsImage = await pictureRecorder
        .endRecording()
        .toImage(size.width.toInt(), size.height.toInt());
    final ByteData? byteData =
        await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData == null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
    
    final Uint8List uint8List = byteData.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(uint8List);
  }

  static void _drawPriceBadge(Canvas canvas, Size size, String text) {
    final Paint badgePaint = Paint()..color = cravnBlack;
    final double badgeHeight = 40;
    final double radius = size.width / 2;
    
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'SF Pro Display',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    
    final double badgeWidth = tp.width + 30; // padding
    
    final RRect badgeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(radius, size.height - 20), // Bottom overlay
        width: badgeWidth,
        height: badgeHeight,
      ),
      const Radius.circular(20),
    );
    
    // Shadow
    canvas.drawShadow(Path()..addRRect(badgeRect), Colors.black, 4, true);
    canvas.drawRRect(badgeRect, badgePaint);
    
    tp.paint(
      canvas,
      Offset(radius - tp.width / 2, size.height - 20 - tp.height / 2),
    );
  }

  static void _drawFallbackIcon(Canvas canvas, double radius, double borderWidth) {
     final icon = Icons.restaurant;
     final TextPainter textPainter = TextPainter(
       textDirection: TextDirection.ltr,
     );
     textPainter.text = TextSpan(
       text: String.fromCharCode(icon.codePoint),
       style: TextStyle(
         fontSize: radius, // Half width
         fontFamily: icon.fontFamily,
         color: cravnPrimary,
       ),
     );
     textPainter.layout();
     textPainter.paint(
       canvas,
       Offset(radius - textPainter.width / 2, radius - textPainter.height / 2),
     );
  }

  static Future<ui.Image> _loadImage(String url) async {
    final Completer<ui.Image> completer = Completer();
    try {
      final ByteData data = await NetworkAssetBundle(Uri.parse(url)).load("");
      ui.decodeImageFromList(data.buffer.asUint8List(), (ui.Image img) {
        return completer.complete(img);
      });
    } catch (e) {
      completer.completeError(e);
    }
    return completer.future;
  }
}

// Helper method to draw image with BoxFit
void paint_image({
  required Canvas canvas,
  required Rect rect,
  required ui.Image image,
  BoxFit fit = BoxFit.contain,
}) {
  final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
  final FittedSizes sizes = applyBoxFit(fit, imageSize, rect.size);
  final Rect inputRect = Alignment.center.inscribe(sizes.source, Offset.zero & imageSize);
  final Rect outputRect = Alignment.center.inscribe(sizes.destination, rect);
  canvas.drawImageRect(image, inputRect, outputRect, Paint());
}
