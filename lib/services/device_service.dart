import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<String> getDeviceId() async {
    // SharedPreferences এ স্টোর করে রাখা unique ID
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');
    
    if (deviceId == null) {
      // নতুন unique ID তৈরি
      deviceId = const Uuid().v4();
      await prefs.setString('device_id', deviceId);
    }
    
    return deviceId;
  }

  Future<String> getDeviceName() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.model;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return iosInfo.name;
    }
    return 'Unknown Device';
  }
}