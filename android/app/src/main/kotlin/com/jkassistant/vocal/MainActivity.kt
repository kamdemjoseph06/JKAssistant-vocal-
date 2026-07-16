package com.jkassistant.vocal

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CALL_CHANNEL = "com.jkassistant.vocal/call"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Canal natif pour composer un appel DIRECTEMENT (ACTION_CALL)
        // url_launcher utilise ACTION_DIAL qui ouvre le composeur sans appeler.
        // ACTION_CALL + permission CALL_PHONE = appel immédiat sans toucher l'écran.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CALL_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "makeCall" -> {
                        val number = call.arguments as? String ?: ""
                        if (number.isBlank()) {
                            result.error("INVALID_NUMBER", "Numéro vide", null)
                            return@setMethodCallHandler
                        }
                        try {
                            val intent = Intent(Intent.ACTION_CALL).apply {
                                data = Uri.parse("tel:$number")
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (e: SecurityException) {
                            // Permission CALL_PHONE refusée au runtime
                            result.error("PERMISSION_DENIED", "Permission CALL_PHONE refusée: ${e.message}", null)
                        } catch (e: Exception) {
                            result.error("CALL_FAILED", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
