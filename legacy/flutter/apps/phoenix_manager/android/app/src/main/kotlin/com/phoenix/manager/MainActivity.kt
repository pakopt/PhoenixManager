package com.phoenix.manager

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Edge-to-edge (Android 15+ / targetSdk 35). Equivalente a enableEdgeToEdge()
        // para FlutterActivity, que não estende ComponentActivity.
        WindowCompat.setDecorFitsSystemWindows(window, false)
        window.isNavigationBarContrastEnforced = false
        super.onCreate(savedInstanceState)
    }
}
