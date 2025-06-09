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
        // Configure appearance like XML
        mathView.layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        )
        mathView.setPadding(10, 10, 10, 10) // padding in pixels
       // mathView.setTextColor(Color.BLACK)
        mathView.visibility = View.VISIBLE
        mathView.config("MathJax") // set rendering engine

        // Enable JS
        mathView.settings.javaScriptEnabled = true

        // Set the expression
        mathView.text = expression

        // Height calculation after page render
        mathView.webViewClient = object : WebViewClient() {
            override fun onPageFinished(view: WebView?, url: String?) {
                // Delay to ensure MathJax is rendered
                mathView.postDelayed({
                    evaluateHeightWithRetry()
                }, 300)
            }
        }
    }

    private fun evaluateHeightWithRetry(retries: Int = 5) {
        mathView.evaluateJavascript(
            """
            (function() {
                var body = document.body, html = document.documentElement;
                var height = Math.max(body.scrollHeight, body.offsetHeight,
                                      html.clientHeight, html.scrollHeight, html.offsetHeight);
                return height.toString();
            })();
            """.trimIndent()
        ) {
            val height = it.replace("\"", "").toIntOrNull()
            if (height != null && height > 50) {
                MethodChannelHandler.sendHeightUpdate(height)
            } else if (retries > 0) {
                mathView.postDelayed({
                    evaluateHeightWithRetry(retries - 1)
                }, 300)
            }
        }
    }

    override fun getView(): View = mathView

    override fun dispose() {}
}

