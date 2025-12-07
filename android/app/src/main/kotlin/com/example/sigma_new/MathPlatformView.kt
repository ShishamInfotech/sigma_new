package com.example.sigma_new

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.webkit.WebView
import android.webkit.WebViewClient
import io.flutter.plugin.platform.PlatformView

class MathPlatformView(context: Context, private val expression: String) : PlatformView {
    private val webView: WebView = WebView(context)

    init {
        try {
            webView.settings.javaScriptEnabled = true
            webView.settings.allowFileAccess = true
            webView.settings.allowFileAccessFromFileURLs = true
            webView.settings.allowUniversalAccessFromFileURLs = true
            webView.settings.domStorageEnabled = true

            webView.webViewClient = WebViewClient()
            webView.setBackgroundColor(android.graphics.Color.TRANSPARENT)
            webView.setLayerType(View.LAYER_TYPE_SOFTWARE, null)
            val safeExpression = if (expression.isBlank()) "1+1" else expression

            Handler(Looper.getMainLooper()).post {
                val html = """
                    <!DOCTYPE html>
                    <html>
                    <head>
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <script type="text/x-mathjax-config">
                          window.MathJax = {
                            loader: {
                              load: ['input/tex', 'output/chtml'], 
                              paths: {mathjax: 'file:///android_asset/mathjax'}
                            },
                            options: {
                              enableMenu: false
                            },
                            tex: {
                              inlineMath: [['\\(','\\)']],
                              displayMath: [['$$','$$']]
                            },
                            svg: { fontCache: 'none' },
                            
                          };
                        </script>
                        <script id="MathJax-script" type="text/javascript" src="file:///android_asset/mathjax/tex-mml-chtml.js"></script>
                        <style>
                            body {
                                font-size: 17px;
                                height: auto;
                                max-height: max-content;
                                margin-top: 15px;
                                margin-bottom:5px;
                            }
                            mjx-container {
                                font-size: 17px;
                                height: auto;
                                max-height: max-content;
                                padding-top: 10px;
                                transform: translateY(6px); /* move everything lower */
                            }
                            
                           
                        </style>
                    </head>
                    <body>
                    
                        $safeExpression
                    </body>
                    </html>
                """.trimIndent()

                webView.loadDataWithBaseURL("file:///android_asset/mathjax/", html, "text/html", "utf-8", null)
            }
        } catch (e: Exception) {
            Log.e("MathPlatformView", "Error initializing WebView: ${e.message}")
        }
    }

    override fun getView(): View = webView

    override fun dispose() {
        try {
            webView.stopLoading()
            webView.loadUrl("about:blank")
            webView.removeAllViews()
            webView.destroy()
        } catch (e: Exception) {
            Log.e("MathPlatformView", "Error destroying WebView: ${e.message}")
        }
    }
}
