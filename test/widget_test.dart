import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spec_check/main.dart'; // 혜성 님의 패키지 이름에 맞게 import

void main() {
  testWidgets('SpecCheck 앱 실행 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SpecCheckApp(),
      ),
    );

    expect(find.byType(SpecCheckApp), findsOneWidget);
  });
}