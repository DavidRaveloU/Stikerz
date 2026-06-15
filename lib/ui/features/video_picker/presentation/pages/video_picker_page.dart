import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/services/video_picker_service.dart';
import 'package:stikerz/core/utils/responsive_text.dart';
import 'package:stikerz/routes/app_router.dart' show routeObserver;
import 'package:stikerz/ui/features/video_picker/presentation/widgets/confirm_bar.dart';
import 'package:stikerz/ui/features/video_picker/presentation/widgets/permission_settings_dialog.dart';
import 'package:stikerz/ui/features/video_picker/presentation/widgets/video_picker_top_bar.dart';
import 'package:stikerz/ui/features/video_picker/presentation/widgets/video_tile.dart';

class VideoPickerPage extends StatefulWidget {
  final Future<PermissionState> Function()? permissionStateLoader;
  final Future<PermissionState> Function()? permissionRequester;
  final Future<List<AssetEntity>> Function()? videosLoader;
  final Future<void> Function()? limitedPickerPresenter;

  const VideoPickerPage({
    super.key,
    this.permissionStateLoader,
    this.permissionRequester,
    this.videosLoader,
    this.limitedPickerPresenter,
  });

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

  /// Loads gallery state and decides the next permission flow step.
  ///
  /// - `notDetermined`: requests permission automatically.
  /// - `hasAccess`: loads videos immediately.
  /// - denied states: shows the blocked UI with manual action.
  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final perm = await _getPermissionState();

    if (!mounted) return;

    if (perm == PermissionState.notDetermined) {
      await _requestAndLoad();
      return;
    }

    if (perm.hasAccess) {
      await _loadVideos(perm);
      return;
    }

    setState(() {
      _permissionDenied = true;
      _isLimitedAccess = false;
      _videos = [];
      _loading = false;
    });
  }

  /// Requests permission using the native platform dialog when available.
  ///
  /// If the OS suppresses the dialog (already permanently denied), this
  /// method shows the settings guidance dialog.
  Future<void> _requestAndLoad() async {
    if (_requestingPermission) return;
    _requestingPermission = true;

    try {
      final before = await _getPermissionState();

      final perm = await _requestPermission();
      if (!mounted) return;

      if (perm.hasAccess) {
        await _loadVideos(perm);
        return;
      }

      // If state stays denied before and after request, the OS likely
      // suppressed the dialog and settings guidance is required.
      final soBlockedDialog =
          !before.hasAccess &&
          before != PermissionState.notDetermined &&
          !perm.hasAccess;

      if (soBlockedDialog && mounted) {
        setState(() {
          _permissionDenied = true;
          _isLimitedAccess = false;
          _videos = [];
          _loading = false;
        });
        await showPermissionSettingsDialog(context);
        return;
      }

      setState(() {
        _permissionDenied = true;
        _isLimitedAccess = false;
        _videos = [];
        _loading = false;
      });
    } finally {
      _requestingPermission = false;
    }
  }

  Future<void> _loadVideos(PermissionState perm) async {
    final videos = await _loadVideosFromGallery();
    if (!mounted) return;

    final isLimited =
        (!perm.isAuth && perm.hasAccess) || perm == PermissionState.limited;

    setState(() {
      _videos = videos;
      _permissionDenied = false;
      _isLimitedAccess = isLimited;
      _loading = false;
    });
  }

  /// Opens the limited-library picker so users can expand selection.
  Future<void> _onLimitedTap() async {
    if (_requestingPermission) return;
    _requestingPermission = true;

    try {
      await _presentLimitedPicker();
    } finally {
      _requestingPermission = false;
    }

    if (mounted) await _load();
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

  Future<PermissionState> _getPermissionState() {
    final loader = widget.permissionStateLoader;
    if (loader != null) return loader();

    return PhotoManager.getPermissionState(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.video,
          mediaLocation: false,
        ),
      ),
    );
  }

  Future<PermissionState> _requestPermission() {
    final requester = widget.permissionRequester;
    if (requester != null) return requester();

    return VideoPickerService.requestPermission();
  }

  Future<List<AssetEntity>> _loadVideosFromGallery() {
    final loader = widget.videosLoader;
    if (loader != null) return loader();

    return VideoPickerService.loadVideos();
  }

  Future<void> _presentLimitedPicker() {
    final presenter = widget.limitedPickerPresenter;
    if (presenter != null) return presenter();

    return VideoPickerService.presentLimitedPicker();
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
            Expanded(child: _buildBody(context)),
            if (_selected != null) ConfirmBar(onConfirm: _confirm),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_permissionDenied) {
      return _buildPermissionDeniedState(context);
    }

    return Column(
      children: [
        if (_isLimitedAccess) _buildLimitedBanner(context),
        if (_videos.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                context.l10n.noVideosFound,
                style: context.responsiveTextStyle(
                  mobileSize: 13,
                  tabletSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          )
        else
          Expanded(child: _buildGrid(context)),
      ],
    );
  }

  Widget _buildPermissionDeniedState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveSize(32, tabletSize: 48),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              color: AppColors.textMuted,
              size: context.responsiveSize(48, tabletSize: 56),
            ),
            SizedBox(height: context.responsiveSize(16, tabletSize: 20)),
            Text(
              context.l10n.noGalleryAccess,
              style: context.responsiveTextStyle(
                mobileSize: 16,
                tabletSize: 18,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.responsiveSize(8, tabletSize: 10)),
            Text(
              context.l10n.galleryAccessNeeded,
              style: context.responsiveTextStyle(
                mobileSize: 13,
                tabletSize: 14,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.responsiveSize(24, tabletSize: 28)),
            GestureDetector(
              onTap: _requestAndLoad,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveSize(24, tabletSize: 28),
                  vertical: context.responsiveSize(13, tabletSize: 14),
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  context.l10n.giveAccess,
                  style: context.responsiveTextStyle(
                    mobileSize: 14,
                    tabletSize: 15,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitedBanner(BuildContext context) {
    return GestureDetector(
      onTap: _onLimitedTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveSize(16, tabletSize: 20),
          vertical: context.responsiveSize(12, tabletSize: 14),
        ),
        color: AppColors.accent.withValues(alpha: 0.12),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppColors.accent,
              size: 18,
            ),
            SizedBox(width: context.responsiveSize(12, tabletSize: 14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.limitedGalleryAccess,
                    style: context.responsiveTextStyle(
                      mobileSize: 13,
                      tabletSize: 14,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: context.responsiveSize(2, tabletSize: 3)),
                  Text(
                    context.l10n.addMoreVideos,
                    style: context.responsiveTextStyle(
                      mobileSize: 11,
                      tabletSize: 12,
                      color: AppColors.accent,
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
    );
  }

  Widget _buildGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _gridColumnsForWidth(constraints.maxWidth);
        return GridView.builder(
          padding: EdgeInsets.all(context.responsiveSize(2, tabletSize: 4)),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: context.responsiveSize(2, tabletSize: 4),
            mainAxisSpacing: context.responsiveSize(2, tabletSize: 4),
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
