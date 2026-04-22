import 'package:firebase_database/firebase_database.dart';
import '../models/health_data.dart';

class IoTService {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref(
    "patients/patient1/history",
  );

  /// Stream of the latest single health data reading (for dashboard live view)
  Stream<HealthData> getLatestHealthData() {
    return _ref.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) {
        return HealthData(
          heartRate: 0,
          spo2: 0,
          temperature: 0.0,
          timestamp: DateTime.now(),
        );
      }
      final map = (data as Map).map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final list = map.values
          .map((e) => HealthData.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list.isNotEmpty
          ? list.first
          : HealthData(
              heartRate: 0,
              spo2: 0,
              temperature: 0.0,
              timestamp: DateTime.now(),
            );
    });
  }

  /// Stream of all health data history (sorted latest first)
  Stream<List<HealthData>> getHealthDataStream() {
    return _ref.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return <HealthData>[];

      final map = (data as Map).map(
        (key, value) => MapEntry(key.toString(), value),
      );

      final list = map.values
          .map((e) => HealthData.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();

      // Sort latest first
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }
}
