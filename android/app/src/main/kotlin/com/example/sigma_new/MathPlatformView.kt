package com.example.sigma_new

import android.content.Context
import android.graphics.Color
import android.view.View
import android.view.ViewGroup
import android.webkit.WebView
import android.webkit.WebViewClient
import io.flutter.plugin.platform.PlatformView
import io.github.kexanie.library.MathView

class MathPlatformView(context: Context, private val expression: String) : PlatformView {
    private val mathView: MathView = MathView(context, null)

    init {
        mathView.settings.javaScriptEnabled = true
        //mathView.text = expression
        // mathView.textSize = 20
        mathView.text = """
    <html>
    <head>
        <style>
            body {
                font-size: 20px;
            }
            mjx-container {
                font-size: 20px;
            }
        </style>
    </head>
    <body>
        $expression
    </body>
    </html>
""".trimIndent()

    }

    override fun getView(): View = mathView

    override fun dispose() {}
}

