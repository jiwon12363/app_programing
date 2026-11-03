import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../fridge/view/fridge_screen.dart';
import '../../recipe/view/recipe_screen.dart';
import '../../scan/view/scan_screen.dart';
import '../viewmodel/main_viewmodel.dart';
import 'widgets/app_bottom_nav_bar.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const _tabs = <Widget>[
    FridgeScreen(),
    ScanScreen(),
    RecipeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MainViewModel>();

    return Scaffold(
      // IndexedStack: 탭 전환 시 각 화면의 상태(스크롤 등)를 유지한다.
      body: IndexedStack(index: viewModel.currentIndex, children: _tabs),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: viewModel.currentIndex,
        onTap: context.read<MainViewModel>().changeTab,
      ),
    );
  }
}
