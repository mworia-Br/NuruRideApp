// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SpeedometerSensorFusion extends StatefulWidget {
  @override
  _SpeedometerSensorFusionState createState() =>
      _SpeedometerSensorFusionState();
}

class _SpeedometerSensorFusionState extends State<SpeedometerSensorFusion> {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  double _currentSpeed = 0.0;
  double _initialTime = 0.0; // time of the first sensor reading

  @override
  void initState() {
    super.initState();
    _subscribeSensors();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    super.dispose();
  }

  _subscribeSensors() async {
    _accelerometerSubscription =
        accelerometerEvents.listen((event) => _handleAccelerometerData(event));
    _gyroscopeSubscription =
        gyroscopeEvents.listen((event) => _handleGyroscopeData(event));
    // Wait a bit for initial sensor data before calculating speed
    await Future.delayed(const Duration(milliseconds: 100));
    _initialTime = DateTime.now().millisecondsSinceEpoch.toDouble();
  }

  void _handleAccelerometerData(AccelerometerEvent event) {
    // Extract acceleration in m/s^2
    final x = event.x;
    final y = event.y;
    final z = event.z;
  }

  void _handleGyroscopeData(GyroscopeEvent event) {
    // Extract rotation rates in rad/s
    final x = event.x;
    final y = event.y;
    final z = event.z;

    // Implement sensor fusion algorithm here to estimate speed
    // This example demonstrates a simplified approach using only accelerometer
    final currentTime = DateTime.now().millisecondsSinceEpoch.toDouble();
    final timeDelta =
        (currentTime - _initialTime) / 1000; // convert milliseconds to seconds
    if (timeDelta > 0) {
      // Assuming constant acceleration (which is not entirely accurate)
      final estimatedSpeed = math.sqrt(x * x + y * y + z * z) * timeDelta;
      setState(() {
        _currentSpeed = estimatedSpeed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speedometer (Sensor Fusion)'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Speed: ${_currentSpeed.toStringAsFixed(2)} m/s',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              '**Note:** This is a simplified approach using only accelerometer data. Accuracy may be limited.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
