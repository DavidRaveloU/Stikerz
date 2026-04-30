import 'package:photo_manager/photo_manager.dart';

/// Servicio responsable de la selección y carga de videos desde la galería del dispositivo.
class VideoPickerService {
  /// Solicita permisos para acceder únicamente a videos.
  /// Retorna el estado real del permiso en Android/iOS.
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

  /// Abre el selector nativo de fotos limitado solo a videos.
  static Future<void> presentLimitedPicker() async {
    await PhotoManager.presentLimited(type: RequestType.video);
  }

  /// Carga una página de videos desde la galería, ordenados por fecha de creación descendente
  /// (los más recientes primero).
  ///
  /// [page]     - Página actual (0-based)
  /// [pageSize] - Cantidad de videos por página
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
