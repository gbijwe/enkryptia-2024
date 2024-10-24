import 'package:flutter/services.dart';
import 'package:location/location.dart';

class EnableInBackground {
  final Location location = Location();
  bool? _enabled;
  String? _error;

  Future<bool> checkBackgroundMode() async {
    _error = null;
    final result = await location.isBackgroundModeEnabled();
    _enabled = result;
    return _enabled!;
  }

  Future<void> toggleBackgroundMode() async {
    _error = null;
    try {
      final result =
          await location.enableBackgroundMode(enable: !(_enabled ?? false));
      _enabled = result;
    } on PlatformException catch (err) {
      _error = err.code;
    }
  }

  bool? get isEnabled => _enabled;
  String? get error => _error;
}