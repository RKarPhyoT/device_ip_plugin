import Flutter
import UIKit
import Network
import SystemConfiguration.CaptiveNetwork

public class DeviceIpPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "device_ip_plugin", binaryMessenger: registrar.messenger())
    let instance = DeviceIpPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getIpAddress":
      guard let args = call.arguments as? [String: Any],
            let networkType = args["networkType"] as? String,
            let ipVersion = args["ipVersion"] as? String else {
        result(["ipv4": nil, "ipv6": nil, "error": "Invalid arguments"])
        return
      }

      getDeviceIpAddress(networkType: networkType, ipVersion: ipVersion, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func getDeviceIpAddress(networkType: String, ipVersion: String, result: @escaping FlutterResult) {
    if !isNetworkAvailable() {
      result(["ipv4": nil, "ipv6": nil, "error": "No internet connection"])
      return
    }

    var ipv4Address: String?
    var ipv6Address: String?

    var ifaddr: UnsafeMutablePointer<ifaddrs>?

    guard getifaddrs(&ifaddr) == 0 else {
      result(["ipv4": nil, "ipv6": nil, "error": "Failed to get network interfaces"])
      return
    }

    defer { freeifaddrs(ifaddr) }

    var ptr = ifaddr
    while ptr != nil {
      defer { ptr = ptr?.pointee.ifa_next }

      guard let interface = ptr?.pointee else { continue }

      let addrFamily = interface.ifa_addr.pointee.sa_family
      if addrFamily != UInt8(AF_INET) && addrFamily != UInt8(AF_INET6) { continue }

      let name = String(cString: interface.ifa_name)

      // Filter by network type
      let shouldProcess: Bool
      switch networkType {
      case "wifi":
        shouldProcess = name.hasPrefix("en") && !name.hasPrefix("en0") // WiFi interfaces
      case "mobile":
        shouldProcess = name.hasPrefix("pdp_ip") // Mobile data interfaces
      default: // "any"
        shouldProcess = !name.hasPrefix("lo") // Exclude loopback
      }

      if !shouldProcess { continue }

      var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))

      if getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                     &hostname, socklen_t(hostname.count),
                     nil, socklen_t(0), NI_NUMERICHOST) == 0 {

        let address = String(cString: hostname)

        if addrFamily == UInt8(AF_INET) && (ipVersion == "ipv4" || ipVersion == "both") {
          if ipv4Address == nil && !address.hasPrefix("127.") {
            ipv4Address = address
          }
        } else if addrFamily == UInt8(AF_INET6) && (ipVersion == "ipv6" || ipVersion == "both") {
          if ipv6Address == nil && !address.hasPrefix("::1") && !address.hasPrefix("fe80") {
            // Remove zone identifier if present
            let cleanAddress = address.components(separatedBy: "%").first ?? address
            ipv6Address = cleanAddress
          }
        }

        // Early exit if we have what we need
        if (ipVersion == "ipv4" && ipv4Address != nil) ||
           (ipVersion == "ipv6" && ipv6Address != nil) ||
           (ipVersion == "both" && ipv4Address != nil && ipv6Address != nil) {
          break
        }
      }
    }

    result([
      "ipv4": ipv4Address,
      "ipv6": ipv6Address,
      "error": nil
    ])
  }

  private func isNetworkAvailable() -> Bool {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    zeroAddress.sin_family = sa_family_t(AF_INET)

    guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
      $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
        SCNetworkReachabilityCreateWithAddress(nil, $0)
      }
    }) else {
      return false
    }

    var flags: SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
      return false
    }

    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)

    return isReachable && !needsConnection
  }
}