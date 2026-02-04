import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewScreen extends StatefulWidget {
  final String templateId;
  const WebviewScreen({super.key, required this.templateId});

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  late WebViewController controller;
  bool webViewLoading = false;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (progress) {
          print("webView is loading progres11111111111111 : $progress");
        },
        onPageStarted: (url) {
          print("page started loading $url");
        },
        onPageFinished: (url) {
          print("page finished $url");
          setState(() {
            webViewLoading = true;
          });
        },
        onWebResourceError: (WebResourceError error) {
          // 웹 리소스 로딩 중 오류 발생
          print('Error: ${error.description}');
        },
        onNavigationRequest: (NavigationRequest request) {
          // 특정 도메인으로의 이동을 막고 싶을 때 사용
          if (request.url.startsWith('https://www.youtube.com/')) {
            print('Blocking navigation to ${request.url}');
            return NavigationDecision.prevent;
          }
          print('Allowing navigation to ${request.url}');
          return NavigationDecision.navigate;
        },
      ))
      ..addJavaScriptChannel('BackBtnAction',
          onMessageReceived: (JavaScriptMessage message) {
        var data = jsonDecode(message.message);

        print("data $data");
        Navigator.of(context).pop();
      })
      ..loadRequest(Uri.parse("http://192.168.68.56:5173/")
          .replace(queryParameters: {"templateId": widget.templateId}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFF1D1E20),
      body: Container(
          child: webViewLoading
              ? WebViewWidget(controller: controller)
              : Center(
                  child: LoadingAnimationWidget.inkDrop(
                      color: Colors.white, size: 100),
                )),
    );
  }
}
