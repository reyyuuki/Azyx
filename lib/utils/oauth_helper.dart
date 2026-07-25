import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OauthHelper {
  static Future<String?> authenticate({
    required BuildContext context,
    required String url,
    required String callbackUrlScheme,
    bool forceWebAuth = false,
  }) async {
    final supportsWebView =
        !forceWebAuth && (Platform.isAndroid || Platform.isIOS);

    if (supportsWebView) {
      try {
        final result = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => OauthWebViewPage(
              url: url,
              callbackUrlScheme: callbackUrlScheme,
            ),
            fullscreenDialog: true,
          ),
        );
        if (result != null) {
          return result;
        }
      } catch (e) {
        debugPrint('WebView login error: $e');
      }
    }

    try {
      final result = await FlutterWebAuth2.authenticate(
        url: url,
        callbackUrlScheme: callbackUrlScheme,
      );
      if (result.isNotEmpty) {
        return result;
      }
    } catch (e) {
      debugPrint('FlutterWebAuth2 error: $e');
    }

    try {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('launchUrlString error: $e');
    }

    return null;
  }
}

class OauthWebViewPage extends StatefulWidget {
  final String url;
  final String callbackUrlScheme;

  const OauthWebViewPage({
    super.key,
    required this.url,
    required this.callbackUrlScheme,
  });

  @override
  State<OauthWebViewPage> createState() => _OauthWebViewPageState();
}

class _OauthWebViewPageState extends State<OauthWebViewPage> {
  bool _finished = false;

  void _checkUrl(WebUri? url) {
    if (url == null || _finished) return;
    final urlString = url.toString();
    if (urlString.startsWith('${widget.callbackUrlScheme}://') ||
        urlString.contains('code=') ||
        urlString.contains('access_token=')) {
      _finished = true;
      Navigator.pop(context, urlString);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWindows = Platform.isWindows;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + (isWindows ? 40.0 : 0.0)),
        child: Padding(
          padding: EdgeInsets.only(top: isWindows ? 40.0 : 0.0),
          child: AppBar(
            title: const Text('Sign In'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          domStorageEnabled: true,
          databaseEnabled: true,
          useShouldOverrideUrlLoading: true,
          transparentBackground: false,
          supportZoom: false,
          userAgent:
              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        ),
        onLoadStart: (controller, url) => _checkUrl(url),
        onLoadStop: (controller, url) => _checkUrl(url),
        onUpdateVisitedHistory: (controller, url, isReload) => _checkUrl(url),
        onReceivedError: (controller, request, error) {
          final url = request.url;
          _checkUrl(url);
          controller.getUrl().then((u) => _checkUrl(u));
          final text = '${url.toString()} ${error.description}';
          if (text.contains('code=') || text.contains('${widget.callbackUrlScheme}://')) {
            final pattern = r'(' + widget.callbackUrlScheme + r'://[^\s"\x27<>]+|https?://[^\s"\x27<>]+[?&]code=[^\s"\x27<>]+)';
            final match = RegExp(pattern).firstMatch(text);
            if (match != null && !_finished) {
              _finished = true;
              Navigator.pop(context, match.group(0));
            }
          }
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          final url = navigationAction.request.url;
          if (url != null) {
            final urlString = url.toString();
            if (urlString.startsWith('${widget.callbackUrlScheme}://') ||
                urlString.contains('code=') ||
                urlString.contains('access_token=')) {
              if (!_finished) {
                _finished = true;
                Navigator.pop(context, urlString);
              }
              return NavigationActionPolicy.CANCEL;
            }
          }
          return NavigationActionPolicy.ALLOW;
        },
      ),
    );
  }
}
