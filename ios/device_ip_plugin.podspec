Pod::Spec.new do |s|
  s.name             = 'device_ip_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin to get device IP addresses.'
  s.description      = <<-DESC
A Flutter plugin to retrieve device IP addresses with support for IPv4/IPv6 and different network types.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  s.swift_version = '5.0'
  
  # Flutter 3.29.2 compatibility
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.resource_bundles = {'device_ip_plugin_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end