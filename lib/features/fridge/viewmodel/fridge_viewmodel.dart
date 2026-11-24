import 'package:flutter/foundation.dart';

import '../model/ingredient.dart';
import '../repository/fridge_repository.dart';

/// 냉장고 식재료 목록을 관리한다.
///
/// 화면에 보이는 목록은 이 클래스가 들고 있고, 저장과 삭제는
/// [FridgeRepository]에 맡긴다.
class FridgeViewModel extends ChangeNotifier {
  FridgeViewModel(this._repository) {
    load();
  }

  final FridgeRepository _repository;
  final List<Ingredient> _items = [];

  /// Whether the first load from the repository is still running.
  bool get isLoading => _isLoading;
  bool _isLoading = true;

  /// Ingredients ordered by the fewest days left until expiry.
  List<Ingredient> get items => List.unmodifiable(_items);

  /// Loads the stored ingredients from the repository.
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items
        ..clear()
        ..addAll(await _repository.fetchAll());
      _sortByExpiry();
    } on Exception catch (error) {
      debugPrint('냉장고 불러오기 실패: $error');
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Keeps [_items] ordered so that indexes stay valid for the screen.
  void _sortByExpiry() {
    _items.sort((a, b) {
      final byExpiry = a.expiryDays.compareTo(b.expiryDays);
      return byExpiry != 0 ? byExpiry : a.name.compareTo(b.name);
    });
  }

  /// Saves [write] in the background so the screen updates without waiting.
  void _save(Future<void> write) {
    write.catchError((Object error) {
      debugPrint('저장 실패: $error');
    });
  }

  void add(Ingredient item) {
    _items.add(item);
    _sortByExpiry();
    notifyListeners();
    _save(_repository.add(item));
  }

  void addAll(Iterable<Ingredient> items) {
    final added = items.toList();
    _items.addAll(added);
    _sortByExpiry();
    notifyListeners();
    _save(_repository.addAll(added));
  }

  Ingredient removeAt(int index) {
    final removed = _items.removeAt(index);
    _selected.remove(removed);
    notifyListeners();
    _save(_repository.remove(removed));
    return removed;
  }

  void insert(int index, Ingredient item) {
    _items.insert(index.clamp(0, _items.length), item);
    _sortByExpiry();
    notifyListeners();
    _save(_repository.add(item));
  }

  final Set<Ingredient> _selected = {};
  bool _isSelecting = false;

  /// Whether the fridge screen is currently in ingredient-picking mode.
  bool get isSelecting => _isSelecting;

  /// Ingredients picked for a recipe, in the same order as [items].
  List<Ingredient> get selectedItems =>
      _items.where(_selected.contains).toList();

  /// Returns whether [item] is picked for a recipe.
  bool isSelected(Ingredient item) => _selected.contains(item);

  /// Starts picking mode, keeping any ingredients that are already picked.
  void startSelecting() {
    _isSelecting = true;
    notifyListeners();
  }

  /// Picks [item], or unpicks it when it is already picked.
  void toggleSelected(Ingredient item) {
    if (!_selected.remove(item)) {
      _selected.add(item);
    }
    notifyListeners();
  }

  /// Leaves picking mode but keeps the picked ingredients for the recipe tab.
  void finishSelecting() {
    _isSelecting = false;
    notifyListeners();
  }

  /// Unpicks everything and leaves picking mode.
  void clearSelection() {
    _selected.clear();
    _isSelecting = false;
    notifyListeners();
  }
}
