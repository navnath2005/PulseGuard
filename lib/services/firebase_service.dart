import 'package:firebase_database/firebase_database.dart';
import '../models/health_data.dart';

/// Service for interacting with Firebase Realtime Database
class FirebaseService {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref(
    "patients/patient1/history",
  );

  /// Save new health data entry to Firebase RTDB
  Future<void> saveHealthData(HealthData data) async {
    try {
      await _ref.push().set(data.toMap());
    } catch (e) {
      debugPrintFirebaseError('saveHealthData', e);
    }
  }

  /// Stream of all health data history from Firebase RTDB
  Stream<List<HealthData>> getHealthHistory() {
    return _ref.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return <HealthData>[];

      final map = (data as Map).map(
        (key, value) => MapEntry(key.toString(), value),
      );

      final list = map.values
          .map((e) => HealthData.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();

      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  /// Get a specific number of recent readings
  Stream<List<HealthData>> getRecentReadings(int count) {
    return _ref
        .orderByChild('timestamp')
        .limitToLast(count)
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      if (data == null) return <HealthData>[];

      final map = (data as Map).map(
        (key, value) => MapEntry(key.toString(), value),
      );

      final list = map.values
          .map((e) => HealthData.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();

      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  // ignore: avoid_print
  void debugPrintFirebaseError(String method, Object error) {
    print('FirebaseService.$method error: $error');
  }
}