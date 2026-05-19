package com.shetech.pakland

import android.annotation.TargetApi
import android.net.Uri
import android.net.http.SslError
import android.os.Build
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import android.webkit.SslErrorHandler
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
class MainActivity : FlutterFragmentActivity() {

    private val CHANNEL = "com.example.washmen/webview"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "configureWebView" -> {
                    configureWebViewSettings()
                    result.success("WebView configured successfully")
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun configureWebViewSettings() {
        // Placeholder — Flutter side handles the actual WebView setup.
        println("Native WebView configuration executed.")
    }

    // ✅ Custom WebViewClient with safer SSL handling for testing
    class CustomWebViewClient : WebViewClient() {

        // Allow SSL errors only for specific test/staging domains
        private val allowedHosts = listOf(
            "demo-ipg.ctdev.comtrust.ae", // your test gateway
            "10.0.2.2",                   // local emulator
            "localhost"                   // local testing
        )

        override fun onReceivedSslError(view: WebView?, handler: SslErrorHandler?, error: SslError?) {
            val host = error?.url?.let { Uri.parse(it).host } ?: ""

            if (allowedHosts.any { host.contains(it, ignoreCase = true) }) {
                println("⚠️ SSL error ignored for allowed host: $host (testing only)")
                handler?.proceed() // only allow for trusted test domains
            } else {
                println("❌ SSL error for production host: $host — canceled for safety")
                handler?.cancel() // block untrusted SSLs
            }
        }

        @TargetApi(Build.VERSION_CODES.N)
        override fun onReceivedError(view: WebView?, request: WebResourceRequest?, error: WebResourceError?) {
            super.onReceivedError(view, request, error)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                println("WebView error: ${error?.description} (Code: ${error?.errorCode})")
            }
        }

        override fun onReceivedError(view: WebView?, errorCode: Int, description: String?, failingUrl: String?) {
            super.onReceivedError(view, errorCode, description, failingUrl)
            println("WebView error: $description (Code: $errorCode) for URL: $failingUrl")
        }

        override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean {
            return false // allow all URLs
        }

        @TargetApi(Build.VERSION_CODES.N)
        override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
            return false // allow all URLs
        }
    }
}