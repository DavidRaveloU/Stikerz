import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stikerz/core/services/video_picker_service.dart';

final videoPickerPermissionProvider = FutureProvider<PermissionState>((
  ref,
) async {
  return await VideoPickerService.requestPermission();
});

final videosProvider = FutureProvider<List<AssetEntity>>((ref) async {
  return await VideoPickerService.loadVideos(pageSize: 100);
});

final selectedVideoProvider = StateProvider<AssetEntity?>((ref) => null);
