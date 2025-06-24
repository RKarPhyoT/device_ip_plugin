import 'package:flutter/material.dart';
import 'package:device_ip_plugin/device_ip_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _ipv4 = 'Unknown';
  String _ipv6 = 'Unknown';
  String _error = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _getIpAddresses();
  }

  Future<void> _getIpAddresses() async {
    setState(() => _loading = true);

    try {
      final result = await DeviceIpPlugin.getIpAddress(
        networkType: NetworkType.any,
        ipVersion: IpVersion.both,
      );

      setState(() {
        _ipv4 = result['ipv4'] ?? 'Not available';
        _ipv6 = result['ipv6'] ?? 'Not available';
        _error = result['error'] ?? '';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Device IP Plugin Example'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_loading)
                Center(child: CircularProgressIndicator()),
              if (_error.isNotEmpty)
                Text('Error: $_error', style: TextStyle(color: Colors.red)),
              SizedBox(height: 20),
              Text('IPv4 Address: $_ipv4', style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text('IPv6 Address: $_ipv6', style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _getSpecificIp(NetworkType.wifi),
                    child: Text('WiFi IP'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _getSpecificIp(NetworkType.mobile),
                    child: Text('Mobile IP'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  DeviceIpPlugin.clearCache();
                  _getIpAddresses();
                },
                child: Text('Refresh (Clear Cache)'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getSpecificIp(NetworkType networkType) async {
    setState(() => _loading = true);

    final result = await DeviceIpPlugin.getIpAddress(
      networkType: networkType,
      ipVersion: IpVersion.both,
    );

    setState(() {
      _ipv4 = result['ipv4'] ?? 'Not available';
      _ipv6 = result['ipv6'] ?? 'Not available';
      _error = result['error'] ?? '';
      _loading = false;
    });
  }
}