package com.saudiexim.saudiexim_mobile_app

import android.content.Context
import android.os.Build
import android.os.Debug
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.BufferedReader
import java.io.InputStreamReader

class MainActivity : FlutterActivity() {
    private val channelName = "saudiexim/security"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler {
                call: MethodCall, result: MethodChannel.Result ->
            when (call.method) {
                "isDeviceRooted" -> result.success(isDeviceRooted())
                "isEmulator" -> result.success(isProbablyEmulator(this))
                "isDebuggerAttached" -> result.success(Debug.isDebuggerConnected())
                "getSecurityState" -> result.success(mapOf(
                    "rooted" to isDeviceRooted(),
                    "emulator" to isProbablyEmulator(this),
                    "debugger" to Debug.isDebuggerConnected()
                ))
                else -> result.notImplemented()
            }
        }
    }

    private fun isDeviceRooted(): Boolean {
        return checkBuildTags() || checkSuPaths() || canExecuteSu()
    }

    private fun checkBuildTags(): Boolean {
        val tags = Build.TAGS
        return tags != null && tags.contains("test-keys")
    }

    private fun checkSuPaths(): Boolean {
        val paths = arrayOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/data/local/xbin/su",
            "/data/local/bin/su"
        )
        return paths.any { path -> File(path).exists() }
    }

    private fun canExecuteSu(): Boolean {
        return try {
            val process = Runtime.getRuntime().exec(arrayOf("/system/xbin/which", "su"))
            val input = BufferedReader(InputStreamReader(process.inputStream))
            val line = input.readLine()
            line != null
        } catch (t: Throwable) {
            false
        }
    }

    private fun isProbablyEmulator(context: Context): Boolean {
        val brand = Build.BRAND
        val device = Build.DEVICE
        val product = Build.PRODUCT
        val model = Build.MODEL
        val manufacturer = Build.MANUFACTURER
        val fingerprint = Build.FINGERPRINT

        if (fingerprint.startsWith("generic") || fingerprint.contains("vbox") || fingerprint.contains("test-keys")) return true
        if (model.contains("Emulator", ignoreCase = true) || model.contains("Android SDK built for x86", ignoreCase = true)) return true
        if (manufacturer.contains("Genymotion", ignoreCase = true)) return true
        if (brand.startsWith("generic") && device.startsWith("generic")) return true
        if (product == "google_sdk" || product == "sdk" || product == "sdk_gphone64_arm64" || product == "sdk_gphone64_x86_64") return true

        // System property check for QEMU
        return getSystemProperty("ro.kernel.qemu") == "1"
    }

    private fun getSystemProperty(key: String): String? {
        return try {
            val clz = Class.forName("android.os.SystemProperties")
            val get = clz.getMethod("get", String::class.java)
            get.invoke(null, key) as? String
        } catch (t: Throwable) {
            null
        }
    }
}
