import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebviewModal extends StatefulWidget {
  final String title;
  final String url;
  final Widget? contentOverride;

  const WebviewModal({
    super.key,
    required this.title,
    required this.url,
    this.contentOverride,
  });

  @override
  State<WebviewModal> createState() => _WebviewModalState();
}

class _WebviewModalState extends State<WebviewModal> {
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: _progress < 1.0
              ? LinearProgressIndicator(value: _progress)
              : const SizedBox.shrink(),
        ),
      ),
      body: SafeArea(
        top: false,
        child:
            widget.contentOverride ??
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
              ),
              onWebViewCreated: (controller) {},
              onProgressChanged: (controller, progress) {
                setState(() => _progress = progress / 100.0);
              },
              shouldOverrideUrlLoading: (controller, navigation) async {
                return NavigationActionPolicy.ALLOW;
              },
            ),
      ),
    );
  }
}
