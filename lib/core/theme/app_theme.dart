import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF61B099); // 메인 컬러

  // 앱 전체 공통 테마 설정
  static ThemeData get lightTheme {
    return ThemeData(
      // 최상단 색상 테마
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor, // 로딩 스피너 기본색으로 작용함
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),

      // 앱 상단 바 기본 스타일
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
      ),

      // 기본 버튼 스타일
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),

      // 네비게이션 바 기본 스타일
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed, // 탭이 4개 이상일 때 움직이지 않도록 고정
      ),

      // 앱 전체의 로딩 스피너 색상을 메인 컬러로 명시적 고정
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),

      // 스펙 수정 바텀 시트 등에 나타나는 안드로이드/iOS의 연보라색 기본 배경 및 틴트 제거
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: Colors.white,
      ),
    );
  }
}