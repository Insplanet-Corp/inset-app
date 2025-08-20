import 'package:flutter/material.dart';

class BottomFixedScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget bottom;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;
  final double bottomPadding;

  const BottomFixedScaffold({
    Key? key,
    this.appBar,
    required this.body,
    required this.bottom,
    this.backgroundColor,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    // 네비게이션 바 유무에 따른 간격. 하지만 새로운 레이아웃 scaffold를 만드는 것이 나을 수 있음.
    this.bottomPadding = 100.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scaffoldBgColor =
        backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          // 콘텐츠 영역
          Positioned.fill(
            child: SingleChildScrollView(
              padding:
                  EdgeInsets.only(left: 16, right: 16, bottom: bottomPadding),
              child: body,
            ),
            // child: SingleChildScrollView(
            //   child: (
            //     Padding(
            //       padding: EdgeInsets.only(
            //           left: 16, right: 16, bottom: bottomPadding),
            //       child: body,
            //     ),
            //   ),
            // ),
          ),

          // 하단 고정 영역
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: bottom,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
