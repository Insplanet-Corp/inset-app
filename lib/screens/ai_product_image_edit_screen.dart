import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/ai_screen.dart';
import 'package:flutter_application_1/theme.dart';
import 'package:flutter_application_1/widgets/custom_button.dart';
import 'package:flutter_application_1/widgets/custom_icon_button.dart';
import 'package:flutter_application_1/widgets/custom_modal_bottom_sheet.dart';
import 'package:flutter_application_1/widgets/custom_text.dart';
import 'package:flutter_application_1/widgets/image_with_fallback.dart';
import 'package:flutter_application_1/widgets/chats/typing_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:webview_flutter/webview_flutter.dart';

// jsonDecode를 사용하기 위해 dart:convert 패키지를 가져옵니다.
import 'dart:convert';

// webview_flutter 패키지와 플랫폼별 기능을 가져옵니다.
// import 'package:webview_flutter/webview_flutter.dart';

import '../widgets/custom_app_bar.dart';

class AiProductImageEditScreen extends StatefulWidget {
  const AiProductImageEditScreen({super.key});

  @override
  _AIProductImageEditScreenState createState() =>
      _AIProductImageEditScreenState();
}

class _AIProductImageEditScreenState extends State<AiProductImageEditScreen> {
  int selectedIndex = 0;

  late final WebViewController _controller;
  String _inputValue = "";

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'JavaBridge',
        onMessageReceived: (JavaScriptMessage message) async {
          setState(() {
            _inputValue = message.message;
          });

          print('🔥 HTML input changed: ${message.message}');

          final data = jsonDecode(message.message);

          if (data['action'] == 'navigate') {
            final buttonId = data['buttonId'];

            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InputEditScreen()),
            );

            if (result != null && result is String) {
              // 입력값을 웹뷰에 다시 반영
              _controller.runJavaScript(
                  "setInputValueFromFlutter('${result.replaceAll("'", "\\'")}');");
            }
          }
        },
      )
      ..loadFlutterAsset('assets/sample.html');
  }

  Future<void> _getInputFromHTML() async {
    final result =
        await _controller.runJavaScriptReturningResult("getInputValue();");
    setState(() {
      _inputValue = result.toString().replaceAll('"', '');
    });
  }

  void _setInputFromFlutter() {
    _controller
        .runJavaScript("setInputValueFromFlutter('Flutter에서 설정한 값 😎');");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(
        title: 'AI 이미지',
        variant: AppBarVariant.up,
        colorMode: 'dark',
        actions: [
          CustomIconButton(
            icon: SvgPicture.asset(
              'assets/icons/layers.svg',
              width: 24,
              height: 24,
            ),
            tooltip: "아이콘 버튼 미디엄",
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                builder: (BuildContext context) {
                  return CustomModalBottomSheet(
                    title: '전체 레이어 변경',
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return ListTile(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          leading: SizedBox(
                            width: 64,
                            height: 64,
                            child: ImageWithFallback(
                              imageUrl: 'assets/images/image_fallback.svg',
                              fallbackImageUrl:
                                  'assets/images/image_fallback.svg',
                              loadingImageAsset:
                                  'assets/images/image_fallback.svg',
                            ),
                          ),
                          title: Text('Item ${index + 1}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 4.0,
                            children: [
                              CustomButton(
                                variant: 'secondary',
                                size: 'small',
                                text: '변경',
                                onPressed: () {},
                              ),
                              CustomButton(
                                variant: 'secondary',
                                size: 'small',
                                text: 'AI 생성',
                                onPressed: () {},
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        );
                      },
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                        height: 1,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          CustomIconButton(
            icon: SvgPicture.asset(
              'assets/icons/layers.svg',
              width: 24,
              height: 24,
            ),
            tooltip: "아이콘 버튼 미디엄",
            onPressed: () {},
          ),
          CustomButton(
            variant: 'secondary',
            size: 'small',
            text: "저장",
            leadingIcon: SvgPicture.asset(
              'assets/icons/download.svg',
              width: 20,
              height: 20,
            ),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 400,
                child: Column(
                  children: [
                    // Expanded 필수
                    Expanded(child: WebViewWidget(controller: _controller)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomText(
                        variant: VariantType.label1,
                        text: '📥 HTML input 값: $_inputValue',
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomButton(
                          onPressed: _getInputFromHTML,
                          text: "값 가져오기",
                        ),
                        CustomButton(
                          onPressed: _setInputFromFlutter,
                          text: "값 설정하기",
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),

              // 🔧 Expanded 제거하고 고정 높이로 변경
              SizedBox(
                height: 300,
                child: _buildViewer(selectedIndex),
              ),

              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // buttonGroup
                    Row(
                      spacing: 8.0,
                      children: [
                        CustomIconButton(
                          icon: SvgPicture.asset(
                            'assets/icons/layers.svg',
                            width: 24,
                            height: 24,
                          ),
                          tooltip: "아이콘 버튼 미디엄",
                          backgroundColor: Colors.white,
                          onPressed: () {
                            print('아이콘 버튼이 눌렸습니다!');
                          },
                        ),
                        CustomIconButton(
                          icon: SvgPicture.asset(
                            'assets/icons/image_save.svg',
                            width: 24,
                            height: 24,
                          ),
                          tooltip: "아이콘 버튼 미디엄",
                          backgroundColor: Colors.white,
                          onPressed: () {
                            print('아이콘 버튼이 눌렸습니다!');
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      height: 96,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 8,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            child: Container(
                              width: 64,
                              height: 96,
                              margin: EdgeInsets.only(
                                  left: index == 0 ? horizontalPadding : 0,
                                  right: index == 7 ? horizontalPadding : 8.0,
                                  bottom: 16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: selectedIndex == index
                                      ? Colors.white
                                      : pointEmphasis,
                                ),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              clipBehavior: Clip
                                  .hardEdge, // borderRadius를 적용하려면 이걸 꼭 줘야 함
                              child: ImageWithFallback(
                                imageUrl: 'assets/images/image_fallback.svg',
                                fallbackImageUrl:
                                    'assets/images/image_fallback.svg',
                                loadingImageAsset:
                                    'assets/images/image_fallback.svg',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewer(int index) {
    return Center(
      child: Text(
        '선택된 섹션: $index',
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
}

class InputEditScreen extends StatefulWidget {
  const InputEditScreen({super.key});

  @override
  State<InputEditScreen> createState() => _InputEditScreenState();
}

class _InputEditScreenState extends State<InputEditScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('입력/수정')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: '입력값'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _controller.text); // 결과 전달
              },
              child: const Text('완료'),
            )
          ],
        ),
      ),
    );
  }
}
