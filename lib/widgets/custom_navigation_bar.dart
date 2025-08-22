import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentPageIndex;
  final ValueChanged<int> onDestinationSelected;

  const CustomNavigationBar({
    super.key,
    required this.currentPageIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: onDestinationSelected,
      selectedIndex: currentPageIndex,
      height: 82,
      backgroundColor: Color(0xFFFFF5F5),
      indicatorColor: Color(0xFFFFF5F5),
      destinations: <Widget>[
        NavigationDestination(
          icon: SvgPicture.asset('assets/icons/template.svg',width: 24.0, height: 24.0, colorFilter: ColorFilter.mode(Color(0xFF141414), BlendMode.srcATop)),
          label: '템플릿',
        ),
        NavigationDestination(
          icon: SvgPicture.asset('assets/icons/ai.svg',width: 24.0, height: 24.0, colorFilter: ColorFilter.mode(Color(0xFF141414), BlendMode.srcATop)),
          label: 'AI',
        ),
        NavigationDestination(
          icon: SvgPicture.asset('assets/icons/library.svg',width: 24.0, height: 24.0, colorFilter: ColorFilter.mode(Color(0xFF141414), BlendMode.srcATop)),
          label: '라이브러리',
        ),
      ],
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: Color(0xFF080808), fontSize: 13, fontWeight: FontWeight.w600); // 선택된 라벨 색상
        } else {
          return const TextStyle(color: Color(0xFFB0B0B0), fontSize: 13, fontWeight: FontWeight.w600); // 비활성화된 라벨 색상
        }
      }),
    );
  }
}
