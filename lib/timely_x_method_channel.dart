import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'timely_x_platform_interface.dart';

/// An implementation of [Timely_xPlatform] that uses method channels.
class MethodChannelTimely_x extends Timely_xPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('timely_x');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
