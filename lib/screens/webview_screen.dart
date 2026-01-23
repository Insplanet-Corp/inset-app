import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewScreen extends StatefulWidget {
  const WebviewScreen({super.key});

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
          print("webView is loading progress : $progress");
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
      ..loadRequest(Uri.parse("http://192.168.68.60:5173"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1D1E20),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF1D1E20),
        actions: [
          IconButton(
            onPressed: () {
              print("layer onPressed");
              // openHalfSheet(context);
            },
            icon: Icon(Icons.layers_outlined),
            iconSize: 30,
          ),
          IconButton(
            onPressed: () {
              print("all out onPressed");
            },
            icon: Icon(Icons.all_out),
            iconSize: 30,
          ),
          SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              print("save btn action");
              // _saveCanvasToGallery();
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: Color(0xFFFF938F)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_sharp),
                  SizedBox(
                    width: 3,
                  ),
                  Text(
                    "저장",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
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
