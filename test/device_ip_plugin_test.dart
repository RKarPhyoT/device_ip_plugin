import 'package:flutter_test/flutter_test.dart';
import 'package:device_ip_plugin/device_ip_plugin.dart';
import 'package:device_ip_plugin/device_ip_plugin_platform_interface.dart';
import 'package:device_ip_plugin/device_ip_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDeviceIpPluginPlatform
    with MockPlatformInterfaceMixin
    implements DeviceIpPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final DeviceIpPluginPlatform initialPlatform = DeviceIpPluginPlatform.instance;

  test('$MethodChannelDeviceIpPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDeviceIpPlugin>());
  });

  test('getPlatformVersion', () async {
    DeviceIpPlugin deviceIpPlugin = DeviceIpPlugin();
    MockDeviceIpPluginPlatform fakePlatform = MockDeviceIpPluginPlatform();
    DeviceIpPluginPlatform.instance = fakePlatform;

    expect(await deviceIpPlugin.getPlatformVersion(), '42');
  });
}
