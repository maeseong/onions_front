import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF61B099); // 메인 컬러

  // 앱 전체 공통 테마 설정
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFFF8F9FA), // 연한 회백색 배경

      // 앱 상단 바 기본 스타일
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
      ),

      // 둥근 형태의 메인 버튼 기본 스타일
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white, // 버튼 글씨 색상
          minimumSize: const Size(double.infinity, 56), // 버튼 크기
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28), // 양끝이 둥근 형태
          ),
        ),
      ),

      // 하단 네비게이션 바 기본 스타일
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryColor, // 선택된 탭은 다크 그린
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed, // 탭이 4개 이상일 때 움직이지 않도록 고정
      ),
    );
  }
}
