package com.example.sigma_new

import io.flutter.plugin.common.MethodChannel

object MethodChannelHandler {
    lateinit var channel: MethodChannel

    fun sendHeightUpdate(height: Int) {
        channel.invokeMethod("onHeightCalculated", height)
    }
}