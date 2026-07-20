package com.jkassistant.vocal

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CALL_CHANNEL = "com.jkassistant.vocal/call"
        private const val WHATSAPP_CHANNEL = "com.jkassistant.vocal/whatsapp"

        // [FIX WA-01] Canaux natifs WhatsApp : ouvre directement WhatsApp
        // avec le numéro et le message pré-rempli, sans passer par wa.me (web).
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── Canal appel téléphonique DIRECT (ACTION_CALL) ─────────────────────
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
                            result.error("PERMISSION_DENIED", "Permission CALL_PHONE refusée: ${e.message}", null)
                        } catch (e: Exception) {
                            result.error("CALL_FAILED", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        // ── Canal WhatsApp natif ──────────────────────────────────────────────
        // Ouvre WhatsApp directement avec le numéro et le message pré-rempli
        // en utilisant le protocole whatsapp:// (pas wa.me → pas de navigateur web)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WHATSAPP_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Envoyer un message WhatsApp
                    "sendMessage" -> {
                        val args = call.arguments as? Map<*, *>
                        val phoneNumber = args?.get("phoneNumber") as? String ?: ""
                        val message = args?.get("message") as? String ?: ""

                        if (phoneNumber.isBlank()) {
                            result.error("INVALID_NUMBER", "Numéro WhatsApp vide", null)
                            return@setMethodCallHandler
                        }

                        try {
                            // [FIX WA-02] Utiliser whatsapp:// URL scheme pour ouvrir
                            // WhatsApp directement avec le message pré-rempli
                            // Format : whatsapp://send?phone=336XXXXXXXX&text=message
                            val whatsappUri = Uri.parse(
                                "whatsapp://send?phone=$phoneNumber&text=${Uri.encode(message)}"
                            )

                            val intent = Intent(Intent.ACTION_VIEW).apply {
                                data = whatsappUri
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                // Forcer l'ouverture dans WhatsApp
                                setPackage("com.whatsapp")
                            }

                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            // Fallback : essayer sans package restriction
                            try {
                                val fallbackUri = Uri.parse(
                                    "whatsapp://send?phone=$phoneNumber&text=${Uri.encode(message)}"
                                )
                                val fallbackIntent = Intent(Intent.ACTION_VIEW).apply {
                                    data = fallbackUri
                                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                }
                                startActivity(fallbackIntent)
                                result.success(true)
                            } catch (e2: Exception) {
                                result.error("WHATSAPP_ERROR", 
                                    "WhatsApp non accessible: ${e2.message}", null)
                            }
                        }
                    }

                    // Lancer un appel WhatsApp
                    "makeCall" -> {
                        val args = call.arguments as? Map<*, *>
                        val phoneNumber = args?.get("phoneNumber") as? String ?: ""

                        if (phoneNumber.isBlank()) {
                            result.error("INVALID_NUMBER", "Numéro WhatsApp vide", null)
                            return@setMethodCallHandler
                        }

                        try {
                            // [FIX WA-03] Ouvrir le profil WhatsApp du contact
                            // whatsapp://send?phone=NUMERO → ouvre le chat
                            // De là l'utilisateur peut lancer l'appel vocal/vidéo
                            // C'est le maximum possible sans API WhatsApp Business
                            val whatsappUri = Uri.parse(
                                "whatsapp://send?phone=$phoneNumber"
                            )

                            val intent = Intent(Intent.ACTION_VIEW).apply {
                                data = whatsappUri
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                setPackage("com.whatsapp")
                            }

                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            try {
                                val fallbackUri = Uri.parse(
                                    "whatsapp://send?phone=$phoneNumber"
                                )
                                val fallbackIntent = Intent(Intent.ACTION_VIEW).apply {
                                    data = fallbackUri
                                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                }
                                startActivity(fallbackIntent)
                                result.success(true)
                            } catch (e2: Exception) {
                                result.error("WHATSAPP_ERROR",
                                    "WhatsApp non accessible: ${e2.message}", null)
                            }
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
