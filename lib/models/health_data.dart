/// Health data model with built-in status computation.
class HealthData {
  final int heartRate;
  final int spo2;
  final double temperature;
  final DateTime timestamp;

  const HealthData({
    required this.heartRate,
    required this.spo2,
    required this.temperature,
    required this.timestamp,
  });

  factory HealthData.fromMap(Map<String, dynamic> map) {
    return HealthData(
      heartRate: (map['heartRate'] as num?)?.toInt() ?? 0,
      spo2: (map['spo2'] as num?)?.toInt() ?? 0,
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'heartRate': heartRate,
      'spo2': spo2,
      'temperature': temperature,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Heart rate health status based on clinical ranges
  HealthStatus get heartRateStatus {
    if (heartRate > 120 || heartRate < 50) return HealthStatus.critical;
    if (heartRate > 100 || heartRate < 60) return HealthStatus.warning;
    return HealthStatus.normal;
  }

  /// Blood oxygen health status based on clinical ranges
  HealthStatus get spo2Status {
    if (spo2 < 90) return HealthStatus.critical;
    if (spo2 < 95) return HealthStatus.warning;
    return HealthStatus.normal;
  }

  /// Temperature health status based on clinical ranges
  HealthStatus get temperatureStatus {
    if (temperature > 39.0 || temperature < 35.0) return HealthStatus.critical;
    if (temperature > 37.5 || temperature < 36.0) return HealthStatus.warning;
    return HealthStatus.normal;
  }

  /// Overall health status (worst of individual statuses)
  HealthStatus get overallStatus {
    final statuses = [heartRateStatus, spo2Status, temperatureStatus];
    if (statuses.contains(HealthStatus.critical)) return HealthStatus.critical;
    if (statuses.contains(HealthStatus.warning)) return HealthStatus.warning;
    return HealthStatus.normal;
  }

  /// Computed health score out of 100
  double get healthScore {
    double score = 100;
    // Heart rate scoring (60-100 normal)
    if (heartRate >= 60 && heartRate <= 100) {
      score -= 0;
    } else if (heartRate >= 50 && heartRate <= 120) {
      score -= 15;
    } else {
      score -= 35;
    }
    // SpO2 scoring (>=95 normal)
    if (spo2 >= 95) {
      score -= 0;
    } else if (spo2 >= 90) {
      score -= 20;
    } else {
      score -= 40;
    }
    // Temperature scoring (36.1-37.2 normal)
    if (temperature >= 36.1 && temperature <= 37.2) {
      score -= 0;
    } else if (temperature >= 35.5 && temperature <= 38.0) {
      score -= 10;
    } else {
      score -= 25;
    }
    return score.clamp(0, 100);
  }
}

/// Health metric status classification
enum HealthStatus { normal, warning, critical }
