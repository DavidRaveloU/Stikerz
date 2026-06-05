import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:stikerz/core/services/video_preparation_service.dart';

void main() {
  test(
    'prepareVideoSource retries after a retryable server response',
    () async {
      var callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        if (callCount == 1) {
          return http.Response('temporary failure', 500);
        }

        return http.Response.bytes(
          [9, 8, 7],
          200,
          headers: {'content-length': '3'},
        );
      });

      final tempDir = await Directory.systemTemp.createTemp('stikerz_retry_');

      final prepared = await VideoPreparationService.prepareVideoSource(
        'https://example.com/video.mp4',
        client: client,
        tempDirectory: tempDir,
      );

      final file = File(prepared);
      expect(callCount, 2);
      expect(await file.readAsBytes(), [9, 8, 7]);

      await file.delete();
      await tempDir.delete(recursive: true);
    },
  );
}
