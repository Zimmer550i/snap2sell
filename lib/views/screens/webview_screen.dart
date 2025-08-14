import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class WebViewScreen extends StatefulWidget {
  final String startUrl;

  const WebViewScreen({super.key, required this.startUrl});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  String? url;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {},

          onUrlChange: (change) {
            setState(() {
              url = change.url;
            });
          },
          onNavigationRequest: (NavigationRequest request) async {
            if (request.url.contains("callback?code=")) {
              // Fetch the body of the callback page  
              try {
                final response = await http.get(Uri.parse(request.url));
                if (!mounted) return NavigationDecision.prevent;

                Navigator.pop(context, response.body);
              } catch (e) {
                Navigator.pop(context, "Error: $e");
              }

              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.startUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () async {
            if (await _controller.canGoBack()) {
              _controller.goBack();
            } else {
              _controller.clearCache();
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            }
          },
          child: Icon(Icons.arrow_back_rounded),
        ),
        title: Text(url ?? "Loading...", style: TextStyle(fontSize: 16)),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
