import 'package:flutter/foundation.dart';

/// 하단 탭 선택 상태를 관리한다.
class MainViewModel extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void changeTab(int index) {
    if (index == _currentIndex) return;
    _currentIndex = index;
    notifyListeners();
  }
}
