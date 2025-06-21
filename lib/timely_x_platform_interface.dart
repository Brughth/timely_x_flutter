import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'timely_x_method_channel.dart';

abstract class Timely_xPlatform extends PlatformInterface {
  /// Constructs a Timely_xPlatform.
  Timely_xPlatform() : super(token: _token);

  static final Object _token = Object();

  static Timely_xPlatform _instance = MethodChannelTimely_x();

  /// The default instance of [Timely_xPlatform] to use.
  ///
  /// Defaults to [MethodChannelTimely_x].
  static Timely_xPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [Timely_xPlatform] when
  /// they register themselves.
  static set instance(Timely_xPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
