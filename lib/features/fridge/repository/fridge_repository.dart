import '../model/ingredient.dart';

/// Reads and writes the ingredients stored in the fridge.
///
/// The view model talks only to this interface, so the data source can change
/// (dummy list, Firestore) without touching the screens.
abstract interface class FridgeRepository {
  /// Loads every stored ingredient.
  Future<List<Ingredient>> fetchAll();

  /// Stores one [item].
  Future<void> add(Ingredient item);

  /// Stores every ingredient in [items].
  Future<void> addAll(Iterable<Ingredient> items);

  /// Removes [item] from the store.
  Future<void> remove(Ingredient item);
}
