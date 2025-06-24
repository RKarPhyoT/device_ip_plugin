package com.example.device_ip_plugin

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.wifi.WifiManager
import android.telephony.TelephonyManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.net.Inet4Address
import java.net.Inet6Address
import java.net.NetworkInterface
import java.util.*

class DeviceIpPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "device_ip_plugin")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getIpAddress" -> {
        val networkType = call.argument<String>("networkType") ?: "any"
        val ipVersion = call.argument<String>("ipVersion") ?: "both"

        try {
          val ipData = getDeviceIpAddress(networkType, ipVersion)
          result.success(ipData)
        } catch (e: Exception) {
          result.success(mapOf(
            "ipv4" to null,
            "ipv6" to null,
            "error" to "No internet connection"
          ))
        }
      }
      else -> result.notImplemented()
    }
  }

  private fun getDeviceIpAddress(networkType: String, ipVersion: String): Map<String, Any?> {
    if (!isNetworkAvailable()) {
      return mapOf(
        "ipv4" to null,
        "ipv6" to null,
        "error" to "No internet connection"
      )
    }

    var ipv4Address: String? = null
    var ipv6Address: String? = null

    try {
      val networkInterfaces = Collections.list(NetworkInterface.getNetworkInterfaces())

      for (networkInterface in networkInterfaces) {
        if (networkInterface.isLoopback || !networkInterface.isUp) continue

        val interfaceName = networkInterface.name.lowercase()

        // Filter by network type
        val shouldProcess = when (networkType) {
          "wifi" -> interfaceName.contains("wlan") || interfaceName.contains("wifi")
          "mobile" -> interfaceName.contains("rmnet") || interfaceName.contains("mobile") ||
                  interfaceName.contains("cellular") || interfaceName.contains("radio")
          else -> true // "any"
        }

        if (!shouldProcess) continue

        val addresses = Collections.list(networkInterface.inetAddresses)

        for (address in addresses) {
          if (address.isLoopbackAddress || address.isLinkLocalAddress) continue

          val hostAddress = address.hostAddress ?: continue

          when {
            address is Inet4Address && (ipVersion == "ipv4" || ipVersion == "both") -> {
              if (ipv4Address == null) {
                ipv4Address = if (hostAddress.contains("%")) {
                  hostAddress.split("%")[0]
                } else hostAddress
              }
            }
            address is Inet6Address && (ipVersion == "ipv6" || ipVersion == "both") -> {
              if (ipv6Address == null) {
                ipv6Address = if (hostAddress.contains("%")) {
                  hostAddress.split("%")[0]
                } else hostAddress
              }
            }
          }

          // Early exit if we have both addresses or only need one type
          if ((ipVersion == "ipv4" && ipv4Address != null) ||
            (ipVersion == "ipv6" && ipv6Address != null) ||
            (ipVersion == "both" && ipv4Address != null && ipv6Address != null)) {
            break
          }
        }
      }
    } catch (e: Exception) {
      return mapOf(
        "ipv4" to null,
        "ipv6" to null,
        "error" to "Failed to retrieve IP address: ${e.message}"
      )
    }

    return mapOf(
      "ipv4" to ipv4Address,
      "ipv6" to ipv6Address,
      "error" to null
    )
  }

  private fun isNetworkAvailable(): Boolean {
    val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

    return try {
      val network = connectivityManager.activeNetwork ?: return false
      val capabilities = connectivityManager.getNetworkCapabilities(network) ?: return false

      capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) &&
              capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
    } catch (e: Exception) {
      false
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}