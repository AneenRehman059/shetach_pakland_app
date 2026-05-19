package com.shetech.pakland

import android.app.Activity
import android.os.Bundle
import android.widget.TextView

class IncomingCallActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Simple UI for SOS popup
        val textView = TextView(this).apply {
            text = "🚨 SOS Alert!\nUser needs help."
            textSize = 24f
            setPadding(50, 200, 50, 200)
        }

        setContentView(textView)
    }
}
