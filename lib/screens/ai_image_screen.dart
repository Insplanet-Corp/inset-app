import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/ai_screen.dart';
import 'package:flutter_application_1/widgets/chats/response_action_list.dart';
import 'package:flutter_application_1/widgets/custom_button.dart';
import 'package:flutter_application_1/widgets/custom_text.dart';
import 'package:flutter_application_1/widgets/image_with_fallback.dart';
import 'package:flutter_application_1/widgets/chats/typing_sequence.dart';
import 'package:flutter_application_1/widgets/chats/typing_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../widgets/custom_app_bar.dart'; // 경로는 프로젝트에 맞게 조정

enum ButtonAction { removeBg, generateAI }

enum ButtonAction2 { saveImage, removeBg, generateAI }

class AIImageScreen extends StatefulWidget {
  const AIImageScreen({super.key});

  @override
  _AIImageScreenState createState() => _AIImageScreenState();
}

class _AIImageScreenState extends State<AIImageScreen> {
  bool showSecondWidget = false;
  bool showThirdWidget = false;
  bool showFourthWidget = false;
  ButtonAction? selectedAction;
  ButtonAction2? selectedAction2;

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  Uint8List? _bgRemovedPng;
  bool _removingBg = false;

  void _handleButtonClick(ButtonAction action) {
    setState(() {
      selectedAction = action;
    });

    if (action == ButtonAction.removeBg) {
      // 배경 제거 로직
      debugPrint("배경 제거 클릭됨");
    } else if (action == ButtonAction.generateAI) {
      // AI 이미지 생성 로직
      debugPrint("AI 이미지 생성 클릭됨");
    }
  }

  void _handleButtonClick2(ButtonAction2 action) {
    setState(() {
      selectedAction2 = action;
    });

    if (action == ButtonAction2.saveImage) {
      debugPrint("이미지 저장");
    } else if (action == ButtonAction2.removeBg) {
      debugPrint("배경 제거 클릭됨");
    } else if (action == ButtonAction2.generateAI) {
      debugPrint("AI 이미지 생성 클릭됨");
    }
  }

  void _openImagePreviewSheet(Uint8List bytes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 화면 거의 전체
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.8), // 뒤 완전 어둡게
      builder: (_) {
        return SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height, // 풀스크린
            width: double.infinity,
            color: Colors.transparent,
            child: Stack(
              children: [
                // 확대/이동 가능
                Center(
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 5.0,
                    child: Image.memory(bytes, fit: BoxFit.contain),
                  ),
                ),

                // 닫기 버튼
                Positioned(
                  top: 50,
                  right: 12,
                  child: IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickFromGallery() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return; // 취소
    // setState(() => _pickedImage = file);
    setState(() {
      _removingBg = true;
      _bgRemovedPng = null;
    });
    try {
      final uri = Uri.parse('http://192.168.68.70:3000/remove-bg');

      final req = http.MultipartRequest('POST', uri);
      req.files.add(await http.MultipartFile.fromPath('image', file.path));

      final streamed = await req.send();
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode != 200) {
        throw Exception('remove-bg 실패: ${resp.statusCode} ${resp.body}');
      }

      // 3) 응답은 image/png 바이트
      setState(() {
        _bgRemovedPng = resp.bodyBytes; // Uint8List
        _removingBg = false;
      });
    } catch (e) {
      setState(() {
        _removingBg = false;
        print(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'AI 이미지',
        variant: AppBarVariant.up,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TODO
              SizedBox(height: 16),
              TypingSequence(
                firstWidget: TypingText(
                  variant: VariantType.h4,
                  text: '어떤 이미지를 만들어 드릴까요?',
                ),
                secondWidget: TypingText(
                  variant: VariantType.label1,
                  text: '상품 이미지만 올려주세요. \nAI가 자동으로 어울리는 배경을 만들어 드려요.',
                ),
                thirdWidget: ResponseActionList(
                  children: [
                    CustomButton(
                        variant: 'secondary',
                        size: 'medium',
                        text: '이미지 배경제거',
                        disabled: selectedAction == ButtonAction.generateAI,
                        onPressed: () =>
                            _handleButtonClick(ButtonAction.removeBg)),
                    CustomButton(
                      variant: 'secondary',
                      size: 'medium',
                      text: 'AI 이미지 생성',
                      disabled: selectedAction == ButtonAction.removeBg,
                      onPressed: () =>
                          _handleButtonClick(ButtonAction.generateAI),
                    ),
                  ],
                ),
              ),

              // CustomText(
              //   variant: VariantType.label1,
              //   text: '상품 이미지만 올려주세요. \nAI가 자동으로 어울리는 배경을 만들어 드려요.',
              //   color: Color(0xFF5D5D5D),
              // ),

              // 배경제거
              if (selectedAction == ButtonAction.removeBg) ...[
                // 텍스트 영역
                SizedBox(height: 16),
                TypingSequence(
                  firstWidget: TypingText(
                    variant: VariantType.h4,
                    text: '상품 이미지를 업로드해주세요.',
                  ),
                  secondWidget: TypingText(
                    variant: VariantType.label1,
                    text: '업로드한 이미지의 배경을 자동으로 제거해 드려요.',
                  ),
                  // thirdWidget: ImageWithFallback(
                  //   imageUrl: 'assets/images/image_fallback.svg',
                  //   fallbackImageUrl: 'assets/images/image_fallback.svg',
                  //   loadingImageAsset: 'assets/images/image_fallback.svg',
                  // ),
                  // fourthWidget: ResponseActionList(
                  //   children: [
                  //     CustomButton(
                  //       variant: 'secondary2',
                  //       size: 'medium',
                  //       text: '이미지 저장',
                  //       disabled: selectedAction == ButtonAction2.generateAI,
                  //       onPressed: () =>
                  //           _handleButtonClick2(ButtonAction2.saveImage),
                  //       leadingIcon: SvgPicture.asset(
                  //         'assets/icons/image_save.svg',
                  //         width: 24,
                  //         height: 24,
                  //         // colorFilter: Color(0xFFDE3B35)),
                  //       ),
                  //     ),
                  //     CustomButton(
                  //       variant: 'secondary2',
                  //       size: 'medium',
                  //       text: '다른 이미지 배경제거',
                  //       disabled: selectedAction == ButtonAction2.generateAI,
                  //       onPressed: () =>
                  //           _handleButtonClick2(ButtonAction2.removeBg),
                  //       leadingIcon: SvgPicture.asset(
                  //         'assets/icons/background_remove.svg',
                  //         width: 24,
                  //         height: 24,
                  //         // colorFilter: Color(0xFFDE3B35)),
                  //       ),
                  //     ),
                  //     CustomButton(
                  //       variant: 'secondary2',
                  //       size: 'medium',
                  //       text: 'AI 이미지 생성',
                  //       disabled: selectedAction == ButtonAction2.generateAI,
                  //       onPressed: () =>
                  //           _handleButtonClick2(ButtonAction2.generateAI),
                  //       leadingIcon: SvgPicture.asset(
                  //         'assets/icons/ai_generate.svg',
                  //         width: 24,
                  //         height: 24,
                  //         // colorFilter: Color(0xFFDE3B35)),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ),
                if (_removingBg) const Text("배경 제거 중..."),

                if (_bgRemovedPng != null)
                  GestureDetector(
                    onTap: () => _openImagePreviewSheet(_bgRemovedPng!),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        _bgRemovedPng!,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
              ],

              if (selectedAction == ButtonAction.generateAI) ...[
                SizedBox(height: 16),
                TypingSequence(
                  firstWidget: TypingText(
                    variant: VariantType.h4,
                    text: '상품 이미지를 업로드해주세요.',
                  ),
                  secondWidget: TypingText(
                    variant: VariantType.label1,
                    text: '업로드한 이미지의 배경을 자동으로 제거해 드려요.',
                  ),
                  thirdWidget: ResponseActionList(
                    children: [
                      CustomButton(
                        variant: 'secondary2',
                        size: 'medium',
                        text: '예시사진 업로드',
                        onPressed: () => {},
                        leadingIcon: SvgPicture.asset(
                          'assets/icons/image_save.svg',
                          width: 24,
                          height: 24,
                          // colorFilter: Color(0xFFDE3B35)),
                        ),
                      ),
                      CustomButton(
                        variant: 'secondary2',
                        size: 'medium',
                        text: '컨셉 직접 설명',
                        onPressed: () => {},
                        leadingIcon: SvgPicture.asset(
                          'assets/icons/background_remove.svg',
                          width: 24,
                          height: 24,
                          // colorFilter: Color(0xFFDE3B35)),
                        ),
                      ),
                      CustomButton(
                        variant: 'secondary2',
                        size: 'medium',
                        text: '어울리는 컨셉 추천',
                        onPressed: () => {},
                        leadingIcon: SvgPicture.asset(
                          'assets/icons/ai_generate.svg',
                          width: 24,
                          height: 24,
                          // colorFilter: Color(0xFFDE3B35)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // SizedBox(height: 16),
              // if (showThirdWidget) ...[
              //   Row(
              //     spacing: 8,
              //     children: [
              //       TypingText(
              //         text: 'AI가 이미지를 만들고 있어요. \n약간의 시간이 소요됩니다.',
              //         onProgress: (progress) {
              //           if (progress > 0.85 && !showFourthWidget) {
              //             setState(() {
              //               showFourthWidget = true;
              //             });
              //           }
              //         },
              //       ),
              //     ],
              //   ),
              //   SizedBox(height: 24),
              // ],

              // if (showFourthWidget) ...[
              //   ImageWithFallback(
              //     imageUrl: 'assets/images/image_fallback.svg',
              //     fallbackImageUrl: 'assets/images/image_fallback.svg',
              //     loadingImageAsset: 'assets/images/image_fallback.svg',
              //   ),
              //   SizedBox(height: 24),
              // ],

              // Container(
              //   width: MediaQuery.of(context).size.width * 0.68,
              //   child: GridView.count(
              //     shrinkWrap: true,
              //     physics: NeverScrollableScrollPhysics(), // 스크롤과 충돌? 방지
              //     primary: false,
              //     // padding: const EdgeInsets.all(20),
              //     crossAxisSpacing: 8,
              //     mainAxisSpacing: 8,
              //     crossAxisCount: 2,
              //     children: <Widget>[
              //       ImageWithFallback(
              //         imageUrl: 'assets/images/image_fallback.svg',
              //         fallbackImageUrl: 'assets/images/image_fallback.svg',
              //         loadingImageAsset: 'assets/images/image_fallback.svg',
              //       ),
              //       ImageWithFallback(
              //         imageUrl: 'assets/images/image_fallback.svg',
              //         fallbackImageUrl: 'assets/images/image_fallback.svg',
              //         loadingImageAsset: 'assets/images/image_fallback.svg',
              //       ),
              //       ImageWithFallback(
              //         imageUrl: 'assets/images/image_fallback.svg',
              //         fallbackImageUrl: 'assets/images/image_fallback.svg',
              //         loadingImageAsset: 'assets/images/image_fallback.svg',
              //       ),
              //       ImageWithFallback(
              //         imageUrl: 'assets/images/image_fallback.svg',
              //         fallbackImageUrl: 'assets/images/image_fallback.svg',
              //         loadingImageAsset: 'assets/images/image_fallback.svg',
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
      // floatingActionButton: selectedAction == ButtonAction.removeBg
      //     ? SafeArea(
      //         child: Padding(
      //           padding: const EdgeInsets.symmetric(horizontal: 24.0),
      //           child: CustomButton(
      //             variant: 'primary',
      //             size: 'large',
      //             text: '이미지 업로드',
      //             isFullWidth: true,
      //             onPressed: () => {},
      //           ),
      //         ),
      //       )
      //     : null,

      floatingActionButton: Align(
        alignment: Alignment.bottomCenter, // 하단 가운데로 정렬
        child: selectedAction == ButtonAction.removeBg
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: CustomButton(
                  variant: 'primary',
                  size: 'large',
                  text: '이미지 업로드',
                  isFullWidth: true,
                  onPressed: () => {_pickFromGallery()},
                ),
              )
            : const SizedBox.shrink(), // null 대신 빈 위젯으로 애니메이션되지 않도록
      ),

      // 구조 왜 이랬나
      // floatingActionButton: selectedAction == ButtonAction.removeBg
      //     ? Align(
      //         alignment: Alignment.bottomCenter,
      //         child: Column(
      //           mainAxisSize: MainAxisSize.min, // Column의 크기를 필요한 만큼만 설정
      //           children: [
      //             Padding(
      //               padding: const EdgeInsets.symmetric(horizontal: 24.0),
      //               child: CustomButton(
      //                 variant: 'primary',
      //                 size: 'large',
      //                 text: '이미지 업로드',
      //                 isFullWidth: true,
      //                 onPressed: () => {},
      //               ),
      //             ),
      //           ],
      //         ),
      //       )
      //     : null, // 조건이 false면 FAB 안 보임

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
