package com.example.sigma_new

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.webkit.WebView
import android.webkit.WebViewClient
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.common.BinaryMessenger

class MathPlatformView(
    context: Context,
    private val messenger: BinaryMessenger,
    private val expression: String
) : PlatformView {

    private val webView: WebView = WebView(context)
    private val channel = MethodChannel(messenger, "mathview-native/height")

    init {
        try {
            webView.settings.javaScriptEnabled = true
            webView.settings.domStorageEnabled = true
            webView.settings.allowFileAccess = true
            webView.settings.allowFileAccessFromFileURLs = true
            webView.settings.allowUniversalAccessFromFileURLs = true

            webView.webViewClient = WebViewClient()
            webView.setBackgroundColor(android.graphics.Color.TRANSPARENT)

            val safeExpression = if (expression.isBlank()) "1+1" else expression

            Handler(Looper.getMainLooper()).post {
                val html = """
                    <!DOCTYPE html>
                    <html>
                    <head>
                      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
                      <script type="text/javascript">
                         function sendHeight() {
                          const math = document.getElementById("math");
                          const height = math.scrollHeight;  
                          if (window.FlutterWebViewChannel) {
                            window.FlutterWebViewChannel.postMessage(height.toString());
                          }
                        }
                        window.MathJax = {
                          loader: { load: ['input/tex', 'output/svg'] },
                          tex: {
                            inlineMath: [['\\(','\\)']],
                            displayMath: [['$$','$$']],
                            packages: {'[+]': ['base', 'ams']}
                          },
                          svg: { fontCache: 'none' },
                          startup: {
                            ready: () => {
                              MathJax.startup.defaultReady();
                              MathJax.startup.promise.then(() => { sendHeight(); });
                            }
                          }
                        };
                      </script>
                      <script id="MathJax-script" type="text/javascript" src="file:///android_asset/mathjax/tex-svg.js"></script>
                      <style>
                        html, body {
                          margin: 0 !important;
                          padding: 0 !important;
                          background: transparent;
                        }
                        .math-wrap {
                          box-sizing: content-box;
                          padding-top: 16px;
                          padding-bottom: 4px;
                          overflow: visible !important;
                        }
                        mjx-container {
                          inline-block !important;
                          vertical-align: middle;
                          overflow: visible !important;
                          margin: 0 !important;
                          padding: 0 !important;
                        }
                        mjx-container[jax="CHTML"] { line-height: 1; }
                      </style>
                    </head>
                    <body>
                      <div class="math-wrap" id="math">
                        $safeExpression
                      </div>
                    </body>
                        <script>
                      // JS bridge for sending height to Flutter
                      window.FlutterWebViewChannel = {
                        postMessage: function(message) {
                          MathHeightBridge.postMessage(message);
                        }
                      };
                    </script>
                    </html>
                """.trimIndent()

                // Add JS interface for Android → Flutter communication
                webView.addJavascriptInterface(object {
                    @android.webkit.JavascriptInterface
                    fun postMessage(height: String) {
                        try {
                            channel.invokeMethod("onHeight", height.toFloat())
                        } catch (e: Exception) {
                            Log.e("MathView", "Height parse error: ${e.message}")
                        }
                    }
                }, "MathHeightBridge")

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