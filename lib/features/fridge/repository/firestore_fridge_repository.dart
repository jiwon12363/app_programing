import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/ingredient.dart';
import 'fridge_repository.dart';

/// Stores ingredients in the Cloud Firestore `ingredients` collection.
///
/// A document keeps the expiry as a date (`expiry_date`) instead of days left,
/// so the days left stay correct as time passes.
class FirestoreFridgeRepository implements FridgeRepository {
  FirestoreFridgeRepository({FirebaseFirestore? firestore})
    : _collection = (firestore ?? FirebaseFirestore.instance).collection(
        'ingredients',
      );

  final CollectionReference<Map<String, dynamic>> _collection;

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Map<String, dynamic> _toDocument(Ingredient item) {
    final expiryDate = _today().add(Duration(days: item.expiryDays));
    return {
      ...item.toJson()..remove('expiry_days'),
      'expiry_date': Timestamp.fromDate(expiryDate),
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  Ingredient _fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final expiry = data['expiry_date'];
    final daysLeft = expiry is Timestamp
        ? expiry.toDate().difference(_today()).inDays
        : 7;
    return Ingredient.fromJson({...data, 'expiry_days': daysLeft})..id = doc.id;
  }

  @override
  Future<List<Ingredient>> fetchAll() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map(_fromDocument).toList();
  }

  @override
  Future<void> add(Ingredient item) {
    // The id is assigned before the first await so a quick delete still works.
    final doc = _collection.doc();
    item.id = doc.id;
    return doc.set(_toDocument(item));
  }

  @override
  Future<void> addAll(Iterable<Ingredient> items) {
    final batch = FirebaseFirestore.instance.batch();
    for (final item in items) {
      final doc = _collection.doc();
      item.id = doc.id;
      batch.set(doc, _toDocument(item));
    }
    return batch.commit();
  }

  @override
  Future<void> remove(Ingredient item) async {
    final id = item.id;
    if (id == null) {
      return;
    }
    await _collection.doc(id).delete();
  }
}
