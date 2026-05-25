package com.davidravelo.stikerz

import android.content.Intent
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

class MainActivity : FlutterActivity() {

    companion object {
        private const val WHATSAPP_CHANNEL = "stikerz/whatsapp"
        private const val INTENT_CHANNEL   = "stikerz/intent"
        private const val TAG              = "StikerzWhatsApp"
    }

    // EventChannel para notificar a Flutter cuando llega un nuevo intent
    // mientras la app ya está abierta (singleTask reutiliza la instancia).
    private var intentEventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Canal WhatsApp (sin cambios)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WHATSAPP_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "exportStickerPack" -> {
                        try {
                            val identifier    = call.argument<String>("identifier")?.trim().orEmpty()
                            val name          = call.argument<String>("name")?.trim().orEmpty()
                            val publisher     = call.argument<String>("publisher")?.trim().orEmpty()
                            val trayImagePath = call.argument<String>("trayImagePath")?.trim().orEmpty()
                            val animated      = call.argument<Boolean>("animated") ?: true
                            @Suppress("UNCHECKED_CAST")
                            val stickers = call.argument<List<Map<String, Any?>>>("stickers") ?: emptyList()

                            if (identifier.isEmpty() || name.isEmpty() || trayImagePath.isEmpty() || stickers.isEmpty()) {
                                result.error("invalid_args", "Faltan datos para exportar el pack.", null)
                                return@setMethodCallHandler
                            }

                            val export = exportPack(
                                identifier    = identifier,
                                name          = name,
                                publisher     = publisher.ifEmpty { "stikerz" },
                                trayImagePath = trayImagePath,
                                stickers      = stickers,
                                animated      = animated,
                            )

                            if (!export.success) {
                                result.error("export_failed", export.error, null)
                                return@setMethodCallHandler
                            }

                            val launched = launchWhatsAppImport(
                                identifier = identifier,
                                name       = name,
                            )

                            if (!launched) {
                                result.error(
                                    "whatsapp_not_found",
                                    "WhatsApp no está instalado o no soporta importación de stickers.",
                                    null,
                                )
                                return@setMethodCallHandler
                            }

                            result.success(true)
                        } catch (t: Throwable) {
                            Log.e(TAG, "exportStickerPack error", t)
                            result.error("native_error", t.message ?: "Error nativo", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        // Canal de eventos para notificar a Flutter sobre nuevos intents.
        // Flutter escucha este stream y cuando recibe un evento sabe que debe
        // resetear el router a home antes de procesar el share entrante.
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, INTENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    intentEventSink = events
                }
                override fun onCancel(arguments: Any?) {
                    intentEventSink = null
                }
            })
    }

    override fun onNewIntent(intent: Intent) {
        // singleTask reutiliza la instancia y llama onNewIntent cuando llega
        // un share externo mientras la app ya está abierta.
        // Actualizamos el intent para que receive_sharing_intent lo procese,
        // y notificamos a Flutter para que limpie el back stack.
        setIntent(intent)
        super.onNewIntent(intent)

        val action = intent.action
        val type   = intent.type

        // Solo notificamos si es un share de texto (TikTok / Instagram)
        if (action == Intent.ACTION_SEND && type?.startsWith("text/") == true) {
            Log.d(TAG, "onNewIntent: share recibido, notificando a Flutter para resetear UI")
            // El evento vacío es suficiente — Flutter solo necesita saber que
            // llegó un nuevo share para limpiar el router antes de procesarlo.
            intentEventSink?.success("new_share")
        }
    }

    // ── Export ────────────────────────────────────────────────────────────

    private data class ExportResult(val success: Boolean, val error: String? = null)

    private fun exportPack(
        identifier: String,
        name: String,
        publisher: String,
        trayImagePath: String,
        stickers: List<Map<String, Any?>>,
        animated: Boolean,
    ): ExportResult {
        val packDir = File(filesDir, "wa_stickers/$identifier")
        if (packDir.exists()) packDir.deleteRecursively()
        packDir.mkdirs()

        val traySource = File(trayImagePath)
        if (!traySource.exists()) {
            return ExportResult(false, "No se encontró la portada del pack.")
        }
        traySource.copyTo(File(packDir, "tray.png"), overwrite = true)

        val stickersJson = JSONArray()
        stickers.forEachIndexed { index, map ->
            val srcPath = (map["filePath"] as? String)?.trim().orEmpty()
            if (srcPath.isEmpty()) return@forEachIndexed

            val src = File(srcPath)
            if (!src.exists()) {
                Log.w(TAG, "Sticker file not found: $srcPath")
                return@forEachIndexed
            }

            val dstName = "sticker_$index.webp"
            src.copyTo(File(packDir, dstName), overwrite = true)

            @Suppress("UNCHECKED_CAST")
            val emojis = (map["emojis"] as? List<String>) ?: listOf("😀")
            val emojiJson = JSONArray().apply { emojis.forEach { put(it) } }

            stickersJson.put(
                JSONObject()
                    .put("file", dstName)
                    .put("emojis", emojiJson)
            )
        }

        if (stickersJson.length() < 3) {
            return ExportResult(false, "El pack necesita al menos 3 stickers válidos.")
        }

        val meta = JSONObject()
            .put("identifier",              identifier)
            .put("name",                    name)
            .put("publisher",               publisher)
            .put("tray_image_file",         "tray.png")
            .put("android_play_store_link", "")
            .put("ios_app_store_link",      "")
            .put("publisher_email",         "")
            .put("publisher_website",       "")
            .put("privacy_policy_website",  "")
            .put("license_agreement_website", "")
            .put("image_data_version", System.currentTimeMillis().toString())
            .put("avoid_cache",             false)
            .put("animated_sticker_pack",   animated)
            .put("stickers",                stickersJson)

        File(packDir, "pack.json").writeText(meta.toString())
        Log.d(TAG, "Pack exported to ${packDir.absolutePath} with ${stickersJson.length()} stickers")
        return ExportResult(true)
    }

    // ── Launch WhatsApp ───────────────────────────────────────────────────

    private fun launchWhatsAppImport(identifier: String, name: String): Boolean {
        val authority = "$packageName.stickercontentprovider"

        fun buildIntent(pkg: String) = Intent("com.whatsapp.intent.action.ENABLE_STICKER_PACK").apply {
            `package` = pkg
            putExtra("sticker_pack_id",       identifier)
            putExtra("sticker_pack_authority", authority)
            putExtra("sticker_pack_name",      name)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        for (pkg in listOf("com.whatsapp", "com.whatsapp.w4b")) {
            try {
                startActivityForResult(buildIntent(pkg), 200)
                Log.d(TAG, "WhatsApp import launched with $pkg")
                return true
            } catch (t: Throwable) {
                Log.w(TAG, "Could not launch $pkg: ${t.message}")
            }
        }
        return false
    }
}