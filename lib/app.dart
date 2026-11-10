import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/fridge/viewmodel/fridge_viewmodel.dart';
import 'features/main/view/main_screen.dart';
import 'features/main/viewmodel/main_viewmodel.dart';

/// 앱 루트 위젯. 전역 Provider 등록과 MaterialApp 설정을 담당한다.
class FridgeApp extends StatelessWidget {
  const FridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MainViewModel()),
        ChangeNotifierProvider(create: (_) => FridgeViewModel()),
        // TODO: ScanViewModel, RecipeViewModel 등록
      ],
      child: MaterialApp(
        title: 'AI 냉장고 파먹기',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const MainScreen(),
      ),
    );
  }
}
