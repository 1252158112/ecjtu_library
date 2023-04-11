import 'package:ecjtu_library/utils/state_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewPage extends StatefulWidget {
  const WebviewPage({super.key});
  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  final StateUtil _stateUtil = Get.find();
  int progress = 0;
  late WebViewController webViewController;

  @override
  void initState() {
    super.initState();
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // ..setBackgroundColor(Theme.of(context).colorScheme.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
            setState(() {
              this.progress = progress;
            });
          },
          onPageFinished: (String url) {
            // 在页面加载完成后添加其他 header
            final WebViewCookieManager cookieManager = WebViewCookieManager();

            final cookieRegex =
                RegExp(r'(_?.*)=([\S\s]*); path=(\S+); HttpOnly');
            final cookieRegex2 =
                RegExp(r'(_.*)=([\S\s]*); path=(\S+); HttpOnly');
            for (String i in _stateUtil.cookie.split(',')) {
              final matches = cookieRegex.allMatches(i);
              for (Match match in matches) {
                final name = match.group(1);
                final value = match.group(2);
                final path = match.group(3);
                cookieManager.setCookie(
                  WebViewCookie(
                    name: name ?? '',
                    value: value ?? '',
                    domain: 'http://lib2.ecjtu.edu.cn/',
                    path: path ?? '/',
                  ),
                );
              }
              final matches2 = cookieRegex2.allMatches(i);
              for (Match match in matches2) {
                final name = match.group(1);
                final value = match.group(2);
                final path = match.group(3);
                cookieManager.setCookie(
                  WebViewCookie(
                    name: name ?? '',
                    value: value ?? '',
                    domain: 'http://lib2.ecjtu.edu.cn/',
                    path: path ?? '/',
                  ),
                );
              }
            }
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith(_stateUtil.link)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_stateUtil.link));
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'toWebview',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('华交微图'),
        ),
        body: Column(
          children: [
            if (progress != 100)
              LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            Expanded(
              child: WebViewWidget(
                controller: webViewController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
