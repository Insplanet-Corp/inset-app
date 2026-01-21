import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser; // 사용자 메시지인지, 다른 사람의 메시지인지 구분
  final DateTime? timestamp;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: isUser ? Colors.white : Colors.black,
            ),
      ),
      child: Align(
        alignment:
            isUser ? Alignment.centerRight : Alignment.centerLeft, // 위치 정렬
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
          decoration: BoxDecoration(
            color: isUser ? Color(0xFF373C42) : Colors.grey[200], // 배경색
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(100),
              topRight: Radius.circular(100),
              bottomLeft: Radius.circular(isUser ? 100 : 20),
              bottomRight: Radius.circular(isUser ? 20 : 100),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 3), // 그림자 위치
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarkdownBody(data: message, selectable: true),
              // Text(
              //   message,
              //   style: TextStyle(
              //     color: isUser ? Colors.white : Colors.black,
              //     fontSize: 16,
              //   ),
              // ),
              // SizedBox(height: 4),
              // Text(
              //   _formatTimestamp(timestamp),
              //   style: TextStyle(
              //     color: isUser ? Colors.white70 : Colors.black54,
              //     fontSize: 12,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
