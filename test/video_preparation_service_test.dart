import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:stikerz/core/services/video_preparation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('prepareVideoSource keeps local paths unchanged', () async {
    const localPath = '/tmp/local-video.mp4';

    final prepared = await VideoPreparationService.prepareVideoSource(
      localPath,
    );

    expect(prepared, localPath);
  });

  test('prepareVideoSource downloads remote content to a temp file', () async {
    final client = MockClient((request) async {
      expect(request.url.toString(), 'https://example.com/video.mp4');
      return http.Response.bytes(
        [1, 2, 3, 4, 5],
        200,
        headers: {'content-length': '5'},
      );
    });

    final tempDir = await Directory.systemTemp.createTemp('stikerz_test_');

    final prepared = await VideoPreparationService.prepareVideoSource(
      'https://example.com/video.mp4',
      client: client,
      tempDirectory: tempDir,
    );

    final file = File(prepared);
    expect(await file.exists(), isTrue);
    expect(await file.readAsBytes(), [1, 2, 3, 4, 5]);

    await file.delete();
    await tempDir.delete(recursive: true);
  });
}
