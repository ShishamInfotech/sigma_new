package com.example.sigma_new

import android.content.Context
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec

class MathViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val expression = (args as? Map<*, *>)?.get("expression") as? String ?: ""
        return MathPlatformView(context, expression)
    }
}

