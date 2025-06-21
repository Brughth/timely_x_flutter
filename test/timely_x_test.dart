import 'package:flutter_test/flutter_test.dart';
import 'package:timely_x/timely_x.dart';
import 'package:timely_x/timely_x_platform_interface.dart';
import 'package:timely_x/timely_x_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTimely_xPlatform
    with MockPlatformInterfaceMixin
    implements Timely_xPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final Timely_xPlatform initialPlatform = Timely_xPlatform.instance;

  test('$MethodChannelTimely_x is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTimely_x>());
  });

  test('getPlatformVersion', () async {
    Timely_x timely_xPlugin = Timely_x();
    MockTimely_xPlatform fakePlatform = MockTimely_xPlatform();
    Timely_xPlatform.instance = fakePlatform;

    expect(await timely_xPlugin.getPlatformVersion(), '42');
  });
}
