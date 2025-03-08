import 'package:flutter/services.dart';

class DeviceIdMethodChannel {
  static const platform = MethodChannel('com.example.sigma_new/device_info');

  static Future<String?> getDeviceId() async {
    try {
      final String? deviceId = await platform.invokeMethod('getAndroidId');
      String de = deviceId!;
      return de;
    } on PlatformException catch (e) {

      return null;
    }
  }
}