import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_health_buddy/main.dart';

void main() {
  testWidgets('App smoke test - MyHealthBuddyApp 렌더링 확인', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MyHealthBuddyApp()),
    );
    // 앱이 오류 없이 실행되는지 확인
    expect(find.byType(MaterialApp), findsNothing); // MaterialApp.router 사용
    expect(find.byType(Router), findsOneWidget);
  });
}
