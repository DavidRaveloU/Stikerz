package com.davidravelo.whaticker

import android.content.ContentProvider
import android.content.ContentValues
import android.content.UriMatcher
import android.content.res.AssetFileDescriptor
import android.database.Cursor
import android.database.MatrixCursor
import android.net.Uri
import android.os.ParcelFileDescriptor
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

class StickerContentProvider : ContentProvider() {

    companion object {
        private const val TAG = "StickerContentProvider"

        private const val MATCH_ALL_PACKS    = 1
        private const val MATCH_ONE_PACK     = 2
        private const val MATCH_STICKERS     = 3
        private const val MATCH_STICKER_FILE = 4

        // Columnas exactas que WhatsApp espera para paquetes
        private val PACK_COLUMNS = arrayOf(
            "sticker_pack_identifier",
            "sticker_pack_name",
            "sticker_pack_publisher",
            "sticker_pack_icon",
            "android_play_store_link",
            "ios_app_download_link",
            "sticker_pack_publisher_email",
            "sticker_pack_publisher_website",
            "sticker_pack_privacy_policy_website",
            "sticker_pack_license_agreement_website",
            "image_data_version",
            "whatsapp_will_not_cache_stickers",
            "animated_sticker_pack",
        )

        // Columnas exactas que WhatsApp espera para stickers
        private val STICKER_COLUMNS = arrayOf(
            "sticker_file_name",
            "sticker_emoji",
            "sticker_accessibility_text",
        )
    }

    private val authority: String by lazy {
        requireNotNull(context).packageName + ".stickercontentprovider"
    }

    private val uriMatcher: UriMatcher by lazy {
        UriMatcher(UriMatcher.NO_MATCH).apply {
            addURI(authority, "metadata",            MATCH_ALL_PACKS)
            addURI(authority, "metadata/*",          MATCH_ONE_PACK)
            addURI(authority, "stickers/*",          MATCH_STICKERS)
            addURI(authority, "stickers_asset/*/*",  MATCH_STICKER_FILE)
        }
    }

    override fun onCreate(): Boolean = true

    override fun query(
        uri: Uri,
        projection: Array<out String>?,
        selection: String?,
        selectionArgs: Array<out String>?,
        sortOrder: String?,
    ): Cursor? {
        Log.d(TAG, "query: $uri")
        return when (uriMatcher.match(uri)) {
            MATCH_ALL_PACKS -> queryAllPacks()
            MATCH_ONE_PACK  -> {
                val id = uri.lastPathSegment ?: return MatrixCursor(PACK_COLUMNS)
                queryOnePack(id)
            }
            MATCH_STICKERS  -> {
                val id = uri.lastPathSegment ?: return MatrixCursor(STICKER_COLUMNS)
                queryStickers(id)
            }
            else -> {
                Log.w(TAG, "query: no match for $uri")
                null
            }
        }
    }

    override fun getType(uri: Uri): String? {
        return when (uriMatcher.match(uri)) {
            MATCH_ALL_PACKS    -> "vnd.android.cursor.dir/vnd.$authority.metadata"
            MATCH_ONE_PACK     -> "vnd.android.cursor.item/vnd.$authority.metadata"
            MATCH_STICKERS     -> "vnd.android.cursor.dir/vnd.$authority.stickers"
            MATCH_STICKER_FILE -> {
                val name = uri.lastPathSegment.orEmpty()
                if (name.endsWith(".png", true)) "image/png" else "image/webp"
            }
            else -> null
        }
    }

    override fun openAssetFile(uri: Uri, mode: String): AssetFileDescriptor? {
        Log.d(TAG, "openAssetFile: $uri")
        if (uriMatcher.match(uri) != MATCH_STICKER_FILE) return null

        val segments = uri.pathSegments
        // URI: stickers/{packId}/{fileName}
        if (segments.size < 3) return null

        val packId   = segments[1]
        val fileName = segments[2]
        val file     = File(packDir(packId), fileName)

        if (!file.exists()) {
            Log.e(TAG, "File not found: ${file.absolutePath}")
            return null
        }

        val pfd = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
        return AssetFileDescriptor(pfd, 0, AssetFileDescriptor.UNKNOWN_LENGTH)
    }

    // ── Queries internas ───────────────────────────────────────────────────

    private fun queryAllPacks(): Cursor {
        val cursor = MatrixCursor(PACK_COLUMNS)
        val root = packsRoot()
        val dirs = root.listFiles()?.filter { it.isDirectory && File(it, "pack.json").exists() }
            ?: emptyList()
        dirs.forEach { dir ->
            val meta = readMeta(dir.name) ?: return@forEach
            cursor.addRow(buildPackRow(meta, dir.name))
        }
        Log.d(TAG, "queryAllPacks: ${cursor.count} packs")
        return cursor
    }

    private fun queryOnePack(identifier: String): Cursor {
        val cursor = MatrixCursor(PACK_COLUMNS)
        val meta = readMeta(identifier) ?: return cursor
        cursor.addRow(buildPackRow(meta, identifier))
        return cursor
    }

    private fun buildPackRow(meta: JSONObject, fallbackId: String): Array<Any> {
        val animated   = meta.optBoolean("animated_sticker_pack", true)
        val avoidCache = meta.optBoolean("avoid_cache", false)
        return arrayOf(
            meta.optString("identifier",                  fallbackId),
            meta.optString("name",                        fallbackId),
            meta.optString("publisher",                   "whaticker"),
            meta.optString("tray_image_file",             "tray.png"),
            meta.optString("android_play_store_link",     ""),
            meta.optString("ios_app_store_link",          ""),
            meta.optString("publisher_email",             ""),
            meta.optString("publisher_website",           ""),
            meta.optString("privacy_policy_website",      ""),
            meta.optString("license_agreement_website",   ""),
            meta.optString("image_data_version",          "1"),
            if (avoidCache) 1 else 0,   // int, no boolean
            if (animated) 1 else 0,     // int, no boolean
        )
    }

    private fun queryStickers(identifier: String): Cursor {
        val cursor = MatrixCursor(STICKER_COLUMNS)
        val meta     = readMeta(identifier) ?: return cursor
        val stickers = meta.optJSONArray("stickers") ?: JSONArray()

        for (i in 0 until stickers.length()) {
            val s    = stickers.optJSONObject(i) ?: continue
            val file = s.optString("file", "")
            if (file.isEmpty()) continue

            val arr    = s.optJSONArray("emojis") ?: JSONArray()
            val emojis = buildString {
                for (j in 0 until arr.length()) {
                    if (j > 0) append(',')
                    append(arr.optString(j))
                }
            }
            cursor.addRow(arrayOf(file, emojis, ""))
        }

        Log.d(TAG, "queryStickers $identifier: ${cursor.count} stickers")
        return cursor
    }

    // ── Helpers ────────────────────────────────────────────────────────────

    private fun readMeta(identifier: String): JSONObject? {
        val file = File(packDir(identifier), "pack.json")
        if (!file.exists()) {
            Log.w(TAG, "pack.json not found for $identifier")
            return null
        }
        return try {
            JSONObject(file.readText())
        } catch (e: Exception) {
            Log.e(TAG, "Failed to parse pack.json for $identifier", e)
            null
        }
    }

    private fun packsRoot(): File =
        File(requireNotNull(context).filesDir, "wa_stickers")

    private fun packDir(identifier: String): File =
        File(packsRoot(), identifier)

    // Operaciones de escritura — no aplica
    override fun insert(uri: Uri, values: ContentValues?): Uri? = null
    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?): Int = 0
    override fun update(uri: Uri, values: ContentValues?, selection: String?, selectionArgs: Array<out String>?): Int = 0
}