import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/ai_screen.dart';
import 'package:flutter_application_1/widgets/chats/response_action_list.dart';
import 'package:flutter_application_1/widgets/chats/chat_bubble.dart';
import 'package:flutter_application_1/widgets/custom_button.dart';
import 'package:flutter_application_1/widgets/custom_text.dart';
import 'package:flutter_application_1/widgets/chats/typing_sequence.dart';
import 'package:flutter_application_1/widgets/chats/typing_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/custom_app_bar.dart'; // 경로는 프로젝트에 맞게 조정
import 'package:http/http.dart' as http;

enum ButtonState {
  nullState, // 초기 상태 또는 비활성화 상태
  productDetail, // 상품 상세 페이지 상태
  instagram, // 인스타그램 상태
  shortform, // 틱톡/쇼츠 상태
}

class ChatMessage {
  final bool isUser;
  final String message;

  ChatMessage({required this.isUser, required this.message});
}

class AiTextScreen extends StatefulWidget {
  const AiTextScreen({super.key});

  @override
  _AiTextScreenState createState() => _AiTextScreenState();
}

class _AiTextScreenState extends State<AiTextScreen> {
  // * instance
  // 첫 버튼 클릭시
  bool selected = false;
  ButtonState selectedButtonState = ButtonState.nullState;

  // User가 TextEditor에 작성한 Text 받아오는 controller
  final TextEditingController _controller = TextEditingController();
  final _scroll = ScrollController();

  // 대화 내용 저장소.
  final List<ChatMessage> _messages = [];

  bool _loading = false;
  final FocusNode _focusNode = FocusNode();

  void _updateButtonState(ButtonState newState) {
    setState(() {
      selected = true;
      selectedButtonState = newState;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  String selectedASK() {
    switch (selectedButtonState) {
      case ButtonState.productDetail:
        return "상품 상세 정보를 작성하려고 합니다.\n작성해야하는 것은 고객후기, 추천, 제품소개, 이용방법, FAQ, 배송정보, 유의사항 등등 약 20줄 정도로 작성해주세요\n아래정보들을 취합해서 작성해주세요.\n";
      case ButtonState.instagram:
        return "상품 상세 정보를 인스타 설명란에 넣으려고 합니다.\n약 15줄 정도로 이모티콘도 넣으면서 작성해주세요.\n아래정보들을 취합해서 작성해주세요.\n";
      case ButtonState.shortform:
        return "상품 상세 정보를 틱톡 또는 쇼츠에 넣으려고 합니다.\n약 15줄 정도로 작성해주세요.\n아래정보들을 취합해서 작성해주세요.\n";
      case ButtonState.nullState:
        return "";
    }
  }

  Future<String> callAI({
    required String text,
  }) async {
    // String finalText =
    //     "상품 상세 정보를 작성하려고 합니다.\n아래 정보들을 취합해서 약 5~10줄 사이로 상세정보 페이지에 넣을 텍스트를 넣어줘\n$text";
    String finalText = selectedASK() + text;
    print(finalText);
    final resp = await http.post(
      Uri.parse('http://192.168.68.70:3000/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "messages": [
          {"role": "user", "content": finalText}
        ]
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception('Proxy error(${resp.statusCode}): ${resp.body}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return (data['text'] ?? '').toString();
  }

  Future<void> _onSendPressed() async {
    final text = _controller.text;
    if (text.isEmpty || _loading) return;

    // 아무것도 들어오지 않았을 경우.
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(isUser: true, message: text));
      _controller.clear();
      _loading = true;
    });
    _scrollToBottom();

    try {
      final aiReply = await callAI(text: text);
      setState(() {
        _messages.add(ChatMessage(isUser: false, message: aiReply));
        _loading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(isUser: false, message: "오류: $e"));
        _loading = false;
      });
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    // 화면 삭제시. 메모리 leak 위험.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = _messages.length + (_loading ? 1 : 0);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'AI 텍스트',
        variant: AppBarVariant.up,
      ),
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(
                vertical: 10.0, horizontal: horizontalPadding),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  // CustomText(
                  //   variant: VariantType.label1,
                  //   text: '상세페이지 제작을 위한 모든 것 \nAI가 도와드려요.',
                  //   color: Color(0xFF5D5D5D),
                  // ),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  // * 상단 영역
                  TypingSequence(
                    firstWidget: TypingText(
                        variant: VariantType.h4, text: '어떤 내용이 필요하세요?'),
                    secondWidget: TypingText(
                      variant: VariantType.label1,
                      text: '상세페이지 내용, SNS 게시물 등 \n상품 홍보를 위한 내용을 자동으로 만들어 드려요.',
                      color: Color(0xFF5D5D5D),
                    ),
                    thirdWidget: ResponseActionList(
                      children: [
                        CustomButton(
                          variant: 'secondary',
                          size: 'medium',
                          text: '상품 상세페이지 내용',
                          onPressed: () {
                            _updateButtonState(ButtonState.productDetail);
                          },
                          disabled:
                              selectedButtonState != ButtonState.nullState,
                        ),
                        CustomButton(
                          variant: 'secondary',
                          size: 'medium',
                          text: '인스타그램',
                          onPressed: () {
                            _updateButtonState(ButtonState.instagram);
                          },
                          disabled:
                              selectedButtonState != ButtonState.nullState,
                        ),
                        CustomButton(
                          variant: 'secondary',
                          size: 'medium',
                          text: '틱톡/쇼츠',
                          onPressed: () {
                            _updateButtonState(ButtonState.shortform);
                          },
                          disabled:
                              selectedButtonState != ButtonState.nullState,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  if (selected)
                    StatusWidget(selectedButtonState: selectedButtonState),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 150),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  if (_loading && i == _messages.length) {
                    return Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("AI가 답변중 ..."),
                    );
                  }
                  final m = _messages[i];
                  return ChatBubble(message: m.message, isUser: m.isUser);
                },
                childCount: totalCount,
              ),
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: _FloatingInputBar(
          controller: _controller,
          onSend: _onSendPressed,
          height: 64,
          focus: _focusNode,
        ),
      ),
    );
  }
}

class _FloatingInputBar extends StatelessWidget {
  const _FloatingInputBar({
    required this.controller,
    required this.onSend,
    required this.height,
    required this.focus,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final double height;
  final FocusNode focus;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: MediaQuery.of(context).size.width - 48,
      child: Material(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(100),
        child: TextField(
          focusNode: focus,
          controller: controller,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
          cursorColor: Colors.grey,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => onSend(),
          decoration: InputDecoration(
            hintText: "AI에게 상세내용을 알려주세요.",
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: onSend,
            ),
          ),
        ),
      ),
    );
  }
}

class StatusWidget extends StatelessWidget {
  final ButtonState selectedButtonState;

  const StatusWidget(
      {super.key, required this.selectedButtonState}); // 상태를 전달받음

  @override
  Widget build(BuildContext context) {
    switch (selectedButtonState) {
      case ButtonState.productDetail:
      case ButtonState.instagram:
      case ButtonState.shortform:
        return Column(
          children: [
            TypingSequence(
              firstWidget: TypingText(
                  variant: VariantType.h4, text: '상품에 대한 내용을 알려주세요.'),
              secondWidget: TypingText(
                variant: VariantType.label1,
                text: '상품의 구체적인 특징이나 상세한 정보를 알려주시면,\n더 완성도 있게 작성할 수 있어요.',
                color: Color(0xFF5D5D5D),
              ),
              thirdWidget: Column(
                spacing: 8.0,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [],
              ),
            ),
          ],
        );
      // case ButtonState.instagram:
      //   return Column(
      //     children: [
      //       Text("인스타그램이 선택되었습니다."),
      //       // Instagram 관련 UI 추가
      //     ],
      //   );
      // case ButtonState.shortform:
      //   return Column(
      //     children: [
      //       Text("틱톡/쇼츠가 선택되었습니다."),
      //       // TikTok/ShortForm 관련 UI 추가
      //     ],
      //   );
      case ButtonState.nullState:
      default:
        return Center(
          child: Text("아직 선택되지 않았습니다."),
        );
    }
  }
}
