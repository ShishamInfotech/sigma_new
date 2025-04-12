package com.example.sigma_new

import android.os.Bundle
import androidx.work.Configuration
import androidx.work.WorkManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.provider.Settings



class MainActivity : FlutterFragmentActivity() {

    private val CHANNEL = "com.example.sigma_new/device_info"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)


        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("mathview-native", MathViewFactory())


        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getAndroidId") {
                val androidId = getAndroidId()
                result.success(androidId)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Initialize WorkManager manually
        WorkManager.initialize(
            applicationContext,
            Configuration.Builder().build()
        )
    }

    private fun getAndroidId(): String {
        return Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
    }



}