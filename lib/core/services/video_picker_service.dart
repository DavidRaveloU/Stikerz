import 'package:photo_manager/photo_manager.dart';

/// Service responsible for selecting and loading videos from the device gallery.
class VideoPickerService {
  /// Requests permission to access videos only.
  /// Returns the actual permission state on Android/iOS.
  static Future<PermissionState> requestPermission() async {
    return await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.video,
          mediaLocation: false,
        ),
      ),
    );
  }

  /// Presents the native photo picker limited to videos only.
  static Future<void> presentLimitedPicker() async {
    await PhotoManager.presentLimited(type: RequestType.video);
  }

  /// Loads one page of videos from the gallery, ordered by creation date descending
  /// (most recent first).
  ///
  /// [page]     - Current page (0-based)
  /// [pageSize] - Number of videos per page
  static Future<List<AssetEntity>> loadVideos({
    int page = 0,
    int pageSize = 80,
  }) async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.video,
      onlyAll: true,
      filterOption: FilterOptionGroup(
        videoOption: const FilterOption(
          durationConstraint: DurationConstraint(min: Duration(seconds: 1)),
        ),
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );

    if (albums.isEmpty) {
      return [];
    }

    return albums.first.getAssetListPaged(page: page, size: pageSize);
  }
}
