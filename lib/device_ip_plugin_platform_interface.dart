import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'device_ip_plugin_method_channel.dart';

abstract class DeviceIpPluginPlatform extends PlatformInterface {
  /// Constructs a DeviceIpPluginPlatform.
  DeviceIpPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static DeviceIpPluginPlatform _instance = MethodChannelDeviceIpPlugin();

  /// The default instance of [DeviceIpPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelDeviceIpPlugin].
  static DeviceIpPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DeviceIpPluginPlatform] when
  /// they register themselves.
  static set instance(DeviceIpPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
