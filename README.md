# Device IP Plugin

A Flutter plugin to retrieve device IP addresses.

## Features

- ✅ IPv4 and IPv6 support
- ✅ WiFi and Mobile network filtering
- ✅ Intelligent caching
- ✅ Offline handling
- ✅ Cross-platform (Android & iOS)

## Installation

Add this to your `pubspec.yaml`:

\`\`\`yaml
dependencies:
  device_ip_plugin:
    git:
      url: https://github.com/RKarPhyoT/device_ip_plugin.git
\`\`\`

## Usage

\`\`\`dart
import 'package:device_ip_plugin/device_ip_plugin.dart';

// Get IP address
final ipv4 = await DeviceIpPlugin.getIpv4Address();
print('IPv4: $ipv4');
\`\`\`

## Platform Support

| Platform | Support |
|----------|---------|
| Android  | ✅      |
| iOS      | ✅      |
| Web      | ❌      |
| Desktop  | ❌      |
