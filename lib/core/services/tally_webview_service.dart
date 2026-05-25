import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TallyWebviewService {
  static const _formUrl = 'https://tally.so/r/1ANG9p';
  static const _formId = '1ANG9p';

  static const _emailId = 'ff670338-3b7a-4096-8543-f37cce4804b9';
  static const _problemId = '959aaf66-57b7-4cf7-a6c8-855e6546e1f1';
  static const _deviceInfoId = '33da5ae7-79c5-46c1-b1e9-027991e4cdef';

  static Future<bool> submitHeadless({
    required String email,
    required String problem,
    required String deviceInfo,
    Duration timeout = const Duration(seconds: 40),
  }) async {
    if (!kIsWeb && (defaultTargetPlatform != TargetPlatform.android)) {
      return false;
    }

    final completer = Completer<bool>();
    late final HeadlessInAppWebView headless;
    var disposed = false;
    var submitted = false;
    var pageProgress = 0;

    Future<void> disposeHeadless() async {
      if (disposed) return;
      disposed = true;
      try {
        await headless.dispose();
      } catch (_) {}
    }

    // We now know the exact localStorage keys Tally uses:
    //   FORM_SESSION_1ANG9p  → JSON with sessionUuid
    //   RESPONDENT           → JSON with respondentUuid  (or the UUID string directly)
    //
    // Strategy:
    //   1. Wait (poll) until both keys exist in localStorage.
    //   2. Extract UUIDs from them.
    //   3. DELETE both keys immediately after reading, so next run gets fresh ones.
    //   4. POST to Tally with those UUIDs.
    final js =
        """
(async function() {
  function log(label, value) {
    try {
      console.log('TALLY_DEBUG:' + JSON.stringify({ label: label, value: value }));
    } catch (e) {}
  }

  function isUuid(v) {
    return typeof v === 'string' &&
      /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\$/i.test(v);
  }

  // Parse a UUID out of a localStorage value (may be raw UUID or JSON)
  function extractUuid(raw) {
    if (!raw) return null;
    if (isUuid(raw)) return raw;
    try {
      var parsed = JSON.parse(raw);
      if (isUuid(parsed)) return parsed;
      // Look one level deep in JSON objects
      if (parsed && typeof parsed === 'object') {
        for (var k of Object.keys(parsed)) {
          if (isUuid(parsed[k])) return parsed[k];
          // Two levels deep
          if (parsed[k] && typeof parsed[k] === 'object') {
            for (var k2 of Object.keys(parsed[k])) {
              if (isUuid(parsed[k][k2])) return parsed[k][k2];
            }
          }
        }
      }
    } catch(e) {}
    return null;
  }

  // ── Step 1: poll until Tally writes the session keys ─────────────────────
  var sessionKey    = 'FORM_SESSION_$_formId';
  var respondentKey = 'RESPONDENT';
  var sessionUuid    = null;
  var respondentUuid = null;

  for (var i = 0; i < 50; i++) {   // up to 10 seconds
    await new Promise(r => setTimeout(r, 200));
    var rawSession    = localStorage.getItem(sessionKey);
    var rawRespondent = localStorage.getItem(respondentKey);
    log('poll', { i: i, rawSession: rawSession ? rawSession.slice(0,200) : null, rawRespondent: rawRespondent ? rawRespondent.slice(0,200) : null });
    sessionUuid    = extractUuid(rawSession);
    respondentUuid = extractUuid(rawRespondent);
    if (isUuid(sessionUuid) && isUuid(respondentUuid)) break;
  }

  log('uuids', { sessionUuid: sessionUuid, respondentUuid: respondentUuid });

  if (!isUuid(sessionUuid) || !isUuid(respondentUuid)) {
    log('direct-response', { ok: false, status: 0, text: 'no-session-after-wait' });
    return;
  }

  // ── Step 2: delete keys NOW so the next submit gets fresh UUIDs ──────────
  localStorage.removeItem(sessionKey);
  localStorage.removeItem(respondentKey);
  log('keys-deleted', true);

  // ── Step 3: POST ──────────────────────────────────────────────────────────
  var payload = {
    sessionUuid:    sessionUuid,
    respondentUuid: respondentUuid,
    responses: {
      '$_emailId':      ${jsonEncode(email)},
      '$_problemId':    ${jsonEncode(problem)},
      '$_deviceInfoId': ${jsonEncode(deviceInfo)},
    },
    captchas:    {},
    isCompleted: true,
    password:    null,
  };

  log('direct-submit', { sessionUuid: sessionUuid, respondentUuid: respondentUuid });

  try {
    var resp = await fetch('https://api.tally.so/forms/$_formId/respond', {
      method: 'POST',
      credentials: 'include',
      headers: {
        'accept': 'application/json, text/plain, */*',
        'content-type': 'application/json',
        'tally-version': '2025-01-15',
      },
      body: JSON.stringify(payload),
    });
    var text = '';
    try { text = await resp.text(); } catch(e) {}
    log('direct-response', { ok: resp.ok, status: resp.status, text: text.slice(0, 500) });
  } catch(e) {
    log('direct-response', { ok: false, status: 0, text: String(e) });
  }
})();
""";

    headless = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(_formUrl)),
      initialSettings: InAppWebViewSettings(
        clearCache: false,
        clearSessionCache: false,
      ),
      onProgressChanged: (controller, progress) {
        pageProgress = progress;
      },
      onLoadStop: (controller, url) async {
        if (kDebugMode) {
          debugPrint('[TallyWebview] onLoadStop progress=$pageProgress');
        }
        if (pageProgress < 100) {
          return;
        }
        if (submitted || disposed || completer.isCompleted) return;
        submitted = true;
        try {
          await controller.evaluateJavascript(source: js);
        } catch (e) {
          if (!completer.isCompleted) completer.completeError(e);
          await disposeHeadless();
        }
      },
      onConsoleMessage: (controller, consoleMessage) {
        final message = consoleMessage.message;
        if (kDebugMode) debugPrint('[TallyWebview] $message');
        if (!message.startsWith('TALLY_DEBUG:')) return;

        try {
          final payload = jsonDecode(message.substring('TALLY_DEBUG:'.length));
          if (payload is! Map) return;
          if (payload['label'] != 'direct-response') return;

          final value = payload['value'];
          final ok = value is Map && value['ok'] == true;

          if (!completer.isCompleted) {
            Future.delayed(const Duration(milliseconds: 800), () async {
              if (!completer.isCompleted) completer.complete(ok);
              await disposeHeadless();
            });
          }
        } catch (_) {}
      },
    );

    try {
      await headless.run();
      return completer.future.timeout(
        timeout,
        onTimeout: () async {
          await disposeHeadless();
          return false;
        },
      );
    } catch (_) {
      try {
        await disposeHeadless();
      } catch (_) {}
      return false;
    }
  }
}
