import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/core/services/video_picker_service.dart';
import 'package:whaticker/routes/app_router.dart' show routeObserver;
import 'package:whaticker/ui/features/video_picker/presentation/widgets/confirm_bar.dart';
import 'package:whaticker/ui/features/video_picker/presentation/widgets/video_picker_top_bar.dart';
import 'package:whaticker/ui/features/video_picker/presentation/widgets/video_tile.dart';

class VideoPickerPage extends StatefulWidget {
  const VideoPickerPage({super.key});

  @override
  State<VideoPickerPage> createState() => _VideoPickerPageState();
}

class _VideoPickerPageState extends State<VideoPickerPage>
    with WidgetsBindingObserver, RouteAware {
  List<AssetEntity> _videos = [];
  bool _loading = true;
  bool _permissionDenied = false;
  bool _isLimitedAccess = false;
  AssetEntity? _selected;
  bool _requestingPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void deactivate() {
    routeObserver.unsubscribe(this);
    super.deactivate();
  }

  /// Se ejecuta cuando se regresa a esta página desde otra ruta
  @override
  void didPopNext() {
    _load();
  }

  @override
  void activate() {
    super.activate();
    _load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load();
    }
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final perm = await PhotoManager.getPermissionState(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.video,
          mediaLocation: false,
        ),
      ),
    );

    if (!mounted) return;

    // Sin acceso
    if (!perm.hasAccess && !perm.isAuth) {
      setState(() {
        _permissionDenied = true;
        _isLimitedAccess = false;
        _loading = false;
        _videos = [];
      });
      return;
    }

    final videos = await VideoPickerService.loadVideos();

    if (!mounted) return;

    // Detectar acceso limitado de forma robusta:
    // hasAccess=true pero isAuth=false  →  limitado en Android
    // PermissionState.limited           →  limitado en iOS
    final isLimited =
        (!perm.isAuth && perm.hasAccess) || perm == PermissionState.limited;

    setState(() {
      _videos = videos;
      _permissionDenied = false;
      _isLimitedAccess = isLimited;
      _loading = false;
    });
  }

  Future<void> _onLimitedTap() async {
    if (_requestingPermission) return;
    _requestingPermission = true;
    try {
      final perm = await VideoPickerService.requestPermission();

      if (perm.hasAccess || perm.isAuth || perm == PermissionState.limited) {
        if (mounted) await _load();
        return;
      }

      await PhotoManager.openSetting();
      if (mounted) await _load();
    } finally {
      _requestingPermission = false;
    }
  }

  Future<void> _confirm() async {
    if (_selected == null) return;
    final file = await _selected!.file;
    if (file == null || !mounted) return;

    Navigator.pop(context, file.path);
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int _gridColumnsForWidth(double width) {
    if (width >= 1100) return 6;
    if (width >= 900) return 5;
    if (width >= 700) return 4;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            VideoPickerTopBar(onBack: () => Navigator.pop(context)),
            Expanded(child: _buildBody()),
            if (_selected != null) ConfirmBar(onConfirm: _confirm),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_permissionDenied) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.textMuted,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Sin acceso a la galería',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Necesitamos acceso a tus videos para crear stickers.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _onLimitedTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.accent.withOpacity(0.3),
                    ),
                  ),
                  child: const Text(
                    'Dar acceso',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mostrar banner de acceso limitado incluso si no hay videos
    if (_isLimitedAccess) {
      return Column(
        children: [
          GestureDetector(
            onTap: _onLimitedTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.accent.withOpacity(0.12),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.accent,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Acceso limitado a galería',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Toca para agregar más videos',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.accent,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          if (_videos.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No se encontraron videos',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = _gridColumnsForWidth(constraints.maxWidth);
                  return GridView.builder(
                    padding: const EdgeInsets.all(2),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                      childAspectRatio: 1,
                    ),
                    itemCount: _videos.length,
                    itemBuilder: (_, i) => VideoTile(
                      asset: _videos[i],
                      isSelected: _selected == _videos[i],
                      formatDuration: _formatDuration,
                      onTap: () => setState(() {
                        _selected = _selected == _videos[i] ? null : _videos[i];
                      }),
                    ),
                  );
                },
              ),
            ),
        ],
      );
    }

    // Sin acceso limitado: mostrar grid normalmente
    if (_videos.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron videos',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _gridColumnsForWidth(constraints.maxWidth);
        return GridView.builder(
          padding: const EdgeInsets.all(2),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            childAspectRatio: 1,
          ),
          itemCount: _videos.length,
          itemBuilder: (_, i) => VideoTile(
            asset: _videos[i],
            isSelected: _selected == _videos[i],
            formatDuration: _formatDuration,
            onTap: () => setState(() {
              _selected = _selected == _videos[i] ? null : _videos[i];
            }),
          ),
        );
      },
    );
  }
}
