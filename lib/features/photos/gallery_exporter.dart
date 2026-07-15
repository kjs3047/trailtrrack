import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';

/// Exports captured photos to the device's shared gallery (MediaStore) so they
/// show up in the standard 사진/갤러리 apps, not only inside TrailTrack.
///
/// Failures are non-fatal by design: the in-app copy (app documents dir) is
/// the source of truth; the gallery copy is a convenience export.
class GalleryExporter {
  const GalleryExporter();

  static const _album = 'TrailTrack';

  /// Returns true when the image landed in the gallery.
  Future<bool> saveImage(Uint8List bytes, {String? name}) async {
    try {
      if (!await Gal.hasAccess(toAlbum: true)) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) return false;
      }
      await Gal.putImageBytes(bytes, album: _album, name: name ?? 'trailtrack');
      return true;
    } catch (e) {
      debugPrint('[gallery] export failed: $e');
      return false;
    }
  }
}
