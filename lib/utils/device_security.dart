import 'dart:async';
import 'package:flutter/services.dart';

class DeviceSecurityState {
  final bool rooted;
  final bool emulator;
  final bool debugger;

  const DeviceSecurityState({
    required this.rooted,
    required this.emulator,
    required this.debugger,
  });

  bool get shouldWarn => rooted || emulator || debugger;
}

class DeviceSecurity {
  static const MethodChannel _channel = MethodChannel('saudiexim/security');

  static Future<bool> isRooted() async {
    try {
      final bool? value = await _channel.invokeMethod<bool>('isDeviceRooted');
      return value ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isEmulator() async {
    try {
      final bool? value = await _channel.invokeMethod<bool>('isEmulator');
      return value ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isDebuggerAttached() async {
    try {
      final bool? value = await _channel.invokeMethod<bool>('isDebuggerAttached');
      return value ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<DeviceSecurityState> getSecurityState() async {
    try {
      final Map<Object?, Object?> map =
          await _channel.invokeMethod<Map<Object?, Object?>>("getSecurityState") ?? {};
      return DeviceSecurityState(
        rooted: (map['rooted'] as bool?) ?? false,
        emulator: (map['emulator'] as bool?) ?? false,
        debugger: (map['debugger'] as bool?) ?? false,
      );
    } catch (_) {
      // Fail closed to non-blocking warning
      return const DeviceSecurityState(rooted: false, emulator: false, debugger: false);
    }
  }
}

