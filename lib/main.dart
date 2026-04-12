import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 세로 방향 고정
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // 상태바 투명 처리
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    const ProviderScope(
      child: MyHealthBuddyApp(),
    ),
  );
}

/// 앱 루트 위젯
/// - ConsumerWidget으로 appRouterProvider를 구독
class MyHealthBuddyApp extends ConsumerWidget {
  const MyHealthBuddyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // go_router 인스턴스를 Riverpod Provider에서 가져옴
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'MyHealthBuddy',
      debugShowCheckedModeBanner: false,

      // 테마 적용 (AppTheme.light)
      theme: AppTheme.light,

      // go_router 연결
      routerConfig: router,
    );
  }
}
