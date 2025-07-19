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

        mathView.settings.javaScriptEnabled = true
        mathView.settings.allowFileAccess = true
        mathView.settings.allowFileAccessFromFileURLs = true
        mathView.settings.allowUniversalAccessFromFileURLs = true
        mathView.settings.domStorageEnabled = true
        // mathView.textSize = 20
        mathView.text = """
    <html>
    <head>
           <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body {
                font-size: 17px;
                height: auto;
                max-height: max-content;
                margin-top: 13px; /* 🛠 Adds visible space above the first line */
            }
            mjx-container {
                font-size: 17px;
                height: auto;
                max-height: max-content;
                padding-top: 8px;  /* 🛠 Extra padding inside MathJax container */

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

