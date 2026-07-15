import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Handles on-disk storage of activity photos and thumbnail generation.
///
/// Photos live under `<appDocs>/photos/<activityId>/`. The thumbnail is a
/// downscaled JPEG used for markers and gallery grids.
class PhotoStorage {
  const PhotoStorage();

  static const int thumbnailMaxDimension = 320;
  static const int thumbnailQuality = 80;

  /// Root directory for an activity's photos. Created if missing.
  Future<Directory> _activityDir(String activityId) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'photos', activityId));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  /// Persist a captured image (given its bytes) as the original + a thumbnail.
  /// Returns the two absolute paths. [photoId] names the files.
  Future<({String originalPath, String thumbnailPath})> save({
    required String activityId,
    required String photoId,
    required Uint8List originalBytes,
  }) async {
    final dir = await _activityDir(activityId);
    final originalPath = p.join(dir.path, '$photoId.jpg');
    final thumbnailPath = p.join(dir.path, '${photoId}_thumb.jpg');

    await File(originalPath).writeAsBytes(originalBytes);

    final thumbBytes = generateThumbnailBytes(originalBytes);
    if (thumbBytes != null) {
      await File(thumbnailPath).writeAsBytes(thumbBytes);
    } else {
      // Decoding failed (unexpected format): fall back to the original as its
      // own thumbnail so the UI always has an image to show.
      await File(thumbnailPath).writeAsBytes(originalBytes);
    }

    return (originalPath: originalPath, thumbnailPath: thumbnailPath);
  }

  /// Pure thumbnail generation — decodes, resizes preserving aspect ratio, and
  /// re-encodes as JPEG. Returns null if the input can't be decoded. Extracted
  /// so it can be unit-tested without the filesystem.
  static Uint8List? generateThumbnailBytes(Uint8List originalBytes) {
    final decoded = img.decodeImage(originalBytes);
    if (decoded == null) return null;
    final resized = (decoded.width >= decoded.height)
        ? img.copyResize(decoded, width: thumbnailMaxDimension)
        : img.copyResize(decoded, height: thumbnailMaxDimension);
    return img.encodeJpg(resized, quality: thumbnailQuality);
  }

  /// Remove all photo files for an activity (used when deleting an activity).
  Future<void> deleteActivityPhotos(String activityId) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'photos', activityId));
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }
}
