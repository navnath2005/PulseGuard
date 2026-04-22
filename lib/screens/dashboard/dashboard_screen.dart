import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/theme/app_theme.dart';
import '../../services/iot_service.dart';
import '../../models/health_data.dart';
import '../../widgets/vital_gauge.dart';
import '../../widgets/graph_widget.dart';
import '../../widgets/alert_banner.dart';
import '../../widgets/dashboard_header.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final IoTService _iotService = IoTService();

  String _getAlertMessage(HealthData data) {
    if (data.spo2 < 90) return 'Dangerously low oxygen saturation detected';
    if (data.heartRate > 120) return 'Heart rate is abnormally elevated';
    if (data.heartRate < 50) return 'Heart rate is critically low';
    if (data.temperature > 38.5) return 'High body temperature detected';
    if (data.spo2 < 95) return 'Blood oxygen is below optimal levels';
    if (data.heartRate > 100) return 'Heart rate is slightly elevated';
    return '';
  }

  AlertLevel _getAlertLevel(HealthData data) {
    if (data.spo2 < 90 || data.heartRate > 120 || data.heartRate < 50) {
      return AlertLevel.critical;
    }
    return AlertLevel.warning;
  }

  String _getStatusLabel(HealthStatus status) {
    switch (status) {
      case HealthStatus.normal:
        return 'Normal';
      case HealthStatus.warning:
        return 'Caution';
      case HealthStatus.critical:
        return 'Critical';
    }
  }

  Color _getStatusColor(HealthStatus status) {
    switch (status) {
      case HealthStatus.normal:
        return AppColors.statusNormal;
      case HealthStatus.warning:
        return AppColors.statusWarning;
      case HealthStatus.critical:
        return AppColors.statusCritical;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D1530),
            AppColors.primaryDark,
            Color(0xFF080B18),
          ],
          stops: [0.0, 0.4, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: StreamBuilder<List<HealthData>>(
          stream: _iotService.getHealthDataStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildLoadingState();
            }

            final allData = snapshot.data!;
            final latest = allData.first;

            // Build chart data (oldest first for left-to-right)
            final chartReversed = allData.reversed.toList();
            final heartSpots = <FlSpot>[];
            final spo2Spots = <FlSpot>[];
            for (int i = 0; i < chartReversed.length; i++) {
              heartSpots.add(FlSpot(
                  i.toDouble(), chartReversed[i].heartRate.toDouble()));
              spo2Spots.add(
                  FlSpot(i.toDouble(), chartReversed[i].spo2.toDouble()));
            }

            final alertMessage = _getAlertMessage(latest);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: DashboardHeader(),
                  ),
                ),

                // Alert banner
                if (alertMessage.isNotEmpty)
                  SliverToBoxAdapter(
                    child: AlertBanner(
                      message: alertMessage,
                      level: _getAlertLevel(latest),
                    ),
                  ),

                // Overall status
                SliverToBoxAdapter(
                  child: _buildOverallStatus(latest),
                ),

                // Section title
                SliverToBoxAdapter(
                  child: _buildSectionTitle('Vital Signs'),
                ),

                // 2x2 Gauge Grid
                SliverToBoxAdapter(
                  child: _buildGaugeGrid(latest),
                ),

                // Section title
                SliverToBoxAdapter(
                  child: _buildSectionTitle('Real-Time Trends'),
                ),

                // Graph
                SliverToBoxAdapter(
                  child: GraphWidget(
                    heartData: heartSpots,
                    spo2Data: spo2Spots,
                  ),
                ),

                // Last updated
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 100),
                    child: Center(
                      child: Text(
                        'Last updated: ${_formatTime(latest.timestamp)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverallStatus(HealthData data) {
    final status = data.overallStatus;
    final statusColor = _getStatusColor(status);
    final statusLabel = _getStatusLabel(status);
    final score = data.healthScore;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withValues(alpha: 0.12),
            statusColor.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              status == HealthStatus.normal
                  ? Icons.check_circle_rounded
                  : status == HealthStatus.warning
                      ? Icons.warning_rounded
                      : Icons.error_rounded,
              color: statusColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall: $statusLabel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Health Score: ${score.toInt()}/100',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Mini score ring
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 4,
                  backgroundColor:
                      AppColors.glassBorder.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(statusColor),
                ),
                Text(
                  '${score.toInt()}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGaugeGrid(HealthData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: VitalGauge(
                  label: 'Heart Rate',
                  value: data.heartRate.toDouble(),
                  minValue: 40,
                  maxValue: 160,
                  unit: 'BPM',
                  color: AppColors.heartRateStart,
                  gradientEnd: AppColors.heartRateEnd,
                  icon: Icons.monitor_heart_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: VitalGauge(
                  label: 'Blood Oxygen',
                  value: data.spo2.toDouble(),
                  minValue: 70,
                  maxValue: 100,
                  unit: '%',
                  color: AppColors.spo2Start,
                  gradientEnd: AppColors.spo2End,
                  icon: Icons.bloodtype_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: VitalGauge(
                  label: 'Temperature',
                  value: data.temperature,
                  minValue: 34,
                  maxValue: 42,
                  unit: '°C',
                  color: AppColors.tempStart,
                  gradientEnd: AppColors.tempEnd,
                  icon: Icons.thermostat_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: VitalGauge(
                  label: 'Health Score',
                  value: data.healthScore,
                  minValue: 0,
                  maxValue: 100,
                  unit: 'pts',
                  color: _getStatusColor(data.overallStatus),
                  gradientEnd: AppColors.accentCyan,
                  icon: Icons.favorite_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated heartbeat loading
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.accentCyan,
                        AppColors.accentPurple,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentCyan.withValues(alpha: 0.3),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.monitor_heart_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'CONNECTING TO SENSORS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.5,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 140,
            child: LinearProgressIndicator(
              backgroundColor: AppColors.surfaceCard,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.accentCyan),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}