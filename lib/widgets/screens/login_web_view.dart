import 'package:flutter/material.dart';
import 'package:scrobble_fm/last_fm_api.dart';
import 'package:scrobble_fm/main.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginWebViewScreen extends StatelessWidget {
  const LoginWebViewScreen({Key key, this.loginUrl}) : super(key: key);

  final String loginUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kAppName)),
      body: WebView(
        initialUrl: loginUrl,
        userAgent: LastFM.userAgent,
        javascriptMode: JavascriptMode.disabled,
      ),
    );
  }
}
