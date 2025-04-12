package com.example.sigma_new

import android.content.Context
import android.view.View
import io.flutter.plugin.platform.PlatformView
import io.github.kexanie.library.MathView

class MathPlatformView(context: Context, private val expression: String) : PlatformView {
    private val mathView: MathView = MathView(context, null)

    init {
        mathView.settings.javaScriptEnabled = true
        mathView.text = expression
    }

    override fun getView(): View = mathView

    override fun dispose() {}
}
