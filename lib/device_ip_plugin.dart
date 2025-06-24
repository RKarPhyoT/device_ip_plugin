import 'dart:async';
import 'package:flutter/services.dart';

enum NetworkType { wifi, mobile, any }
enum IpVersion { ipv4, ipv6, both }

class DeviceIpPlugin {
  static const MethodChannel _channel = MethodChannel('device_ip_plugin');

  // Cache for IP addresses with timestamps
  static final Map<String, Map<String, dynamic>> _cache = {};
  static const int _cacheExpirationMs = 30000; // 30 seconds

  /// Get IP address with specified network type and IP version
  static Future<Map<String, String?>> getIpAddress({
    NetworkType networkType = NetworkType.any,
    IpVersion ipVersion = IpVersion.both,
    bool useCache = true,
  }) async {
    final cacheKey = '${networkType.name}_${ipVersion.name}';

    // Check cache first
    if (useCache && _isCacheValid(cacheKey)) {
      final cachedData = _cache[cacheKey]!['data'] as Map<String, String?>;
      return Map<String, String?>.from(cachedData);
    }

    try {
      final Map<Object?, Object?> result = await _channel.invokeMethod(
        'getIpAddress',
        {
          'networkType': networkType.name,
          'ipVersion': ipVersion.name,
        },
      );

      final Map<String, String?> ipData = {
        'ipv4': result['ipv4'] as String?,
        'ipv6': result['ipv6'] as String?,
        'error': result['error'] as String?,
      };

      // Cache the result
      if (useCache) {
        _cache[cacheKey] = {
          'data': ipData,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
      }

      return ipData;
    } on PlatformException catch (e) {
      return {
        'ipv4': null,
        'ipv6': null,
        'error': e.message ?? 'Unknown error occurred',
      };
    }
  }

  /// Get only IPv4 address
  static Future<String?> getIpv4Address({
    NetworkType networkType = NetworkType.any,
    bool useCache = true,
  }) async {
    final result = await getIpAddress(
      networkType: networkType,
      ipVersion: IpVersion.ipv4,
      useCache: useCache,
    );
    return result['ipv4'];
  }

  /// Get only IPv6 address
  static Future<String?> getIpv6Address({
    NetworkType networkType = NetworkType.any,
    bool useCache = true,
  }) async {
    final result = await getIpAddress(
      networkType: networkType,
      ipVersion: IpVersion.ipv6,
      useCache: useCache,
    );
    return result['ipv6'];
  }

  /// Clear the cache
  static void clearCache() {
    _cache.clear();
  }

  /// Check if cached data is still valid
  static bool _isCacheValid(String key) {
    if (!_cache.containsKey(key)) return false;

    final timestamp = _cache[key]!['timestamp'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;

    return (now - timestamp) < _cacheExpirationMs;
  }
}