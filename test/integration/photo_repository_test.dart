import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trailtrack/core/database/app_database.dart';
import 'package:trailtrack/core/utils/activity_type.dart';
import 'package:trailtrack/features/photos/data/photo_repository.dart';
import 'package:trailtrack/features/recording/data/activity_repository.dart';

void main() {
  late AppDatabase db;
  late PhotoRepository photos;
  late ActivityRepository activities;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    photos = PhotoRepository(db);
    activities = ActivityRepository(db);
    // A photo needs its parent activity (FK).
    await activities.createActivity(
      id: 'a1',
      type: ActivityType.walk,
      startedAt: DateTime(2026, 1, 1, 9),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> addPhoto({String? caption}) => photos.insertPhoto(
    id: 'p1',
    activityId: 'a1',
    localPath: '/tmp/p1.jpg',
    thumbnailPath: '/tmp/p1_thumb.jpg',
    takenAt: DateTime(2026, 1, 1, 9, 5),
    elapsedSeconds: 300,
    distanceMeters: 400,
    caption: caption,
  );

  test('caption is null by default', () async {
    await addPhoto();
    final list = await photos.getPhotos('a1');
    expect(list.single.caption, isNull);
  });

  test('updateCaption sets and then updates the caption', () async {
    await addPhoto();
    await photos.updateCaption('p1', '남산 정상');
    expect((await photos.getPhotos('a1')).single.caption, '남산 정상');

    await photos.updateCaption('p1', '남산 전망대');
    expect((await photos.getPhotos('a1')).single.caption, '남산 전망대');
  });

  test('updateCaption trims surrounding whitespace', () async {
    await addPhoto();
    await photos.updateCaption('p1', '  한강공원  ');
    expect((await photos.getPhotos('a1')).single.caption, '한강공원');
  });

  test('empty or whitespace-only caption clears it to null', () async {
    await addPhoto(caption: '지울 메모');
    await photos.updateCaption('p1', '   ');
    expect((await photos.getPhotos('a1')).single.caption, isNull);

    await photos.updateCaption('p1', '다시 메모');
    await photos.updateCaption('p1', '');
    expect((await photos.getPhotos('a1')).single.caption, isNull);
  });
}
