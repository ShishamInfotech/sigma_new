package com.example.sigma_new

import android.content.Context
import android.util.Log
import android.view.View
import io.flutter.plugin.platform.PlatformView
import io.github.kexanie.library.MathView

class MathPlatformView(context: Context, private val expression: String) : PlatformView {
    private val mathView: MathView = MathView(context, null)

    init {
        try {
            mathView.settings.javaScriptEnabled = true
            mathView.settings.allowFileAccess = true
            mathView.settings.allowFileAccessFromFileURLs = true
            mathView.settings.allowUniversalAccessFromFileURLs = true
            mathView.settings.domStorageEnabled = true

            // Safe fallback for empty or null expressions
            val safeExpression = if (expression.isBlank()) "1+1" else expression

            mathView.text = """
                <html>
                <head>
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <style>
                        body {
                            font-size: 17px;
                            height: auto;
                            max-height: max-content;
                            margin-top: 13px;
                            margin-bottom:5px;
                        }
                        mjx-container {
                            font-size: 17px;
                            height: auto;
                            max-height: max-content;
                            padding-top: 8px;
                        }
                    </style>
                </head>
                <body>

                    $safeExpression
                </body>
                </html>
            """.trimIndent()
        } catch (e: Exception) {
            Log.e("MathPlatformView", "Error initializing MathView: ${e.message}")
        }
    }

    override fun getView(): View = mathView

    override fun dispose() {
        // Clean up if needed
        try {
            mathView.destroy()
        } catch (e: Exception) {
            Log.e("MathPlatformView", "Error destroying MathView: ${e.message}")
        }
    }
}
