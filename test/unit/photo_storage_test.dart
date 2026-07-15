import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:trailtrack/features/photos/photo_storage.dart';

void main() {
  test('generateThumbnailBytes downscales a large image', () {
    // Build a 1000x600 red test image.
    final source = img.Image(width: 1000, height: 600);
    img.fill(source, color: img.ColorRgb8(255, 0, 0));
    final jpg = Uint8List.fromList(img.encodeJpg(source));

    final thumb = PhotoStorage.generateThumbnailBytes(jpg);
    expect(thumb, isNotNull);

    final decoded = img.decodeImage(thumb!)!;
    // Landscape → width clamped to thumbnailMaxDimension (320).
    expect(decoded.width, PhotoStorage.thumbnailMaxDimension);
    expect(decoded.height, lessThan(source.height));
  });

  test('generateThumbnailBytes returns null for undecodable input', () {
    final garbage = Uint8List.fromList(List.filled(32, 0));
    expect(PhotoStorage.generateThumbnailBytes(garbage), isNull);
  });
}
