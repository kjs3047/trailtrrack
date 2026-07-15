import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';

/// A horizontal thumbnail strip for an activity's photos (spec §9). Tapping a
/// thumbnail opens the full-screen gallery at that photo.
class PhotoStrip extends StatelessWidget {
  const PhotoStrip({super.key, required this.photos});

  final List<ActivityPhotoRow> photos;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final photo = photos[i];
          return GestureDetector(
            onTap: () => openGallery(context, photos, i),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _thumb(photo),
            ),
          );
        },
      ),
    );
  }

  Widget _thumb(ActivityPhotoRow photo) {
    final file = File(photo.thumbnailPath);
    return SizedBox(
      width: 88,
      height: 88,
      child: file.existsSync()
          ? Image.file(file, fit: BoxFit.cover)
          : Container(
              color: AppColors.surfaceContainerHigh,
              child: const Icon(Icons.image_not_supported_outlined),
            ),
    );
  }
}

/// Opens the full-screen swipeable gallery.
void openGallery(
  BuildContext context,
  List<ActivityPhotoRow> photos,
  int initialIndex,
) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) =>
          _GalleryScreen(photos: photos, initialIndex: initialIndex),
    ),
  );
}

class _GalleryScreen extends ConsumerStatefulWidget {
  const _GalleryScreen({required this.photos, required this.initialIndex});

  final List<ActivityPhotoRow> photos;
  final int initialIndex;

  @override
  ConsumerState<_GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<_GalleryScreen> {
  late final PageController _pageController;
  late int _index;

  /// Local caption overrides (photoId → caption) so edits show immediately
  /// without re-fetching the whole list.
  final Map<String, String?> _captions = {};

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String? _captionOf(ActivityPhotoRow photo) =>
      _captions.containsKey(photo.id) ? _captions[photo.id] : photo.caption;

  Future<void> _editCaption(ActivityPhotoRow photo) async {
    final controller = TextEditingController(text: _captionOf(photo) ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('메모'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          maxLength: 200,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: '어디인지, 무슨 일이 있었는지 기록해 보세요',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('저장'),
          ),
        ],
      ),
    );
    if (result == null) return; // cancelled
    final trimmed = result.trim();
    final value = trimmed.isEmpty ? null : trimmed;
    try {
      await ref.read(photoRepositoryProvider).updateCaption(photo.id, value);
    } catch (e, st) {
      debugPrint('[caption] SAVE FAILED: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('메모 저장 실패: $e')),
        );
      }
      return;
    }
    // The detail screen loads photos via a one-shot FutureProvider, so its
    // cached list is stale after this write. Invalidate it so reopening the
    // gallery (or the strip) reflects the saved caption from the DB.
    ref.invalidate(activityDetailProvider(photo.activityId));
    if (!mounted) return;
    setState(() => _captions[photo.id] = value);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('메모가 저장되었습니다'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photos[_index];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_index + 1} / ${widget.photos.length}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.photos.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final file = File(widget.photos[i].localPath);
                return InteractiveViewer(
                  child: Center(
                    child: file.existsSync()
                        ? Image.file(file, fit: BoxFit.contain)
                        : const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white54,
                            size: 64,
                          ),
                  ),
                );
              },
            ),
          ),
          _MetaBar(
            photo: photo,
            caption: _captionOf(photo),
            onEditCaption: () => _editCaption(photo),
          ),
        ],
      ),
    );
  }
}

class _MetaBar extends StatelessWidget {
  const _MetaBar({
    required this.photo,
    required this.caption,
    required this.onEditCaption,
  });

  final ActivityPhotoRow photo;
  final String? caption;
  final VoidCallback onEditCaption;

  @override
  Widget build(BuildContext context) {
    final hasLoc = photo.latitude != null && photo.longitude != null;
    final hasCaption = caption != null && caption!.isNotEmpty;
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Caption / memo row: shows the text (or a prompt) and an edit icon.
            InkWell(
              onTap: onEditCaption,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        hasCaption ? caption! : '메모 추가',
                        style: TextStyle(
                          color: hasCaption ? Colors.white : Colors.white54,
                          fontSize: 15,
                          fontStyle: hasCaption
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      hasCaption ? Icons.edit_outlined : Icons.add_comment_outlined,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.white24, height: 16),
            Text(
              '${Formatters.duration(Duration(seconds: photo.elapsedSeconds))} · '
              '${Formatters.distanceKm(photo.distanceMeters)} km',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            if (hasLoc)
              Text(
                '${photo.latitude!.toStringAsFixed(5)}, '
                '${photo.longitude!.toStringAsFixed(5)}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              )
            else
              const Text(
                '위치 정보 없음',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}
