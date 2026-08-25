package com.example.steam_tahmin_frontend

import android.content.ContentValues
import android.content.Intent
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.steam_tahmin_frontend/gallery"
    private var channel: MethodChannel? = null
    private var initialDeepLink: String? = null

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        initialDeepLink = intent?.dataString
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val deepLink = intent.dataString
        if (deepLink != null) {
            channel?.invokeMethod("onDeepLink", deepLink)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val ch = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel = ch

        ch.setMethodCallHandler { call, result ->
            if (call.method == "getInitialLink") {
                result.success(initialDeepLink)
                initialDeepLink = null
            } else if (call.method == "saveImageToGallery") {
                val bytes = call.argument<ByteArray>("imageBytes")
                val title = call.argument<String>("title") ?: "steam_tahmin_${System.currentTimeMillis()}"

                if (bytes == null) {
                    result.error("INVALID_BYTES", "Image bytes cannot be null", null)
                    return@setMethodCallHandler
                }

                try {
                    val saved = saveToMediaStore(bytes, title)
                    if (saved) {
                        result.success(true)
                    } else {
                        result.error("SAVE_FAILED", "Could not save to MediaStore", null)
                    }
                } catch (e: Exception) {
                    result.error("EXCEPTION", e.message, null)
                }
            } else if (call.method == "shareText") {
                val text = call.argument<String>("text") ?: ""
                val subject = call.argument<String>("subject") ?: "1v1 Steam Tahmin Düello Daveti"
                try {
                    val sendIntent = Intent().apply {
                        action = Intent.ACTION_SEND
                        putExtra(Intent.EXTRA_TEXT, text)
                        putExtra(Intent.EXTRA_SUBJECT, subject)
                        type = "text/plain"
                    }
                    val shareIntent = Intent.createChooser(sendIntent, "Düello Davetini Paylaş")
                    activity.startActivity(shareIntent)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("SHARE_ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun saveToMediaStore(bytes: ByteArray, title: String): Boolean {
        val filename = "$title.png"

        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val resolver = contentResolver
                val contentValues = ContentValues().apply {
                    put(MediaStore.MediaColumns.DISPLAY_NAME, filename)
                    put(MediaStore.MediaColumns.MIME_TYPE, "image/png")
                    put(MediaStore.MediaColumns.RELATIVE_PATH, "Pictures/SteamTahmin")
                    put(MediaStore.Images.Media.IS_PENDING, 1)
                }

                val imageUri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
                if (imageUri != null) {
                    resolver.openOutputStream(imageUri)?.use { fos ->
                        fos.write(bytes)
                        fos.flush()
                    }
                    contentValues.clear()
                    contentValues.put(MediaStore.Images.Media.IS_PENDING, 0)
                    resolver.update(imageUri, contentValues, null, null)

                    try {
                        sendBroadcast(Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, imageUri))
                    } catch (_: Exception) {}

                    true
                } else {
                    false
                }
            } else {
                val imagesDir = File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES), "SteamTahmin")
                if (!imagesDir.exists()) {
                    imagesDir.mkdirs()
                }
                val imageFile = File(imagesDir, filename)
                FileOutputStream(imageFile).use { fos ->
                    fos.write(bytes)
                    fos.flush()
                }

                MediaScannerConnection.scanFile(
                    applicationContext,
                    arrayOf(imageFile.absolutePath),
                    arrayOf("image/png"),
                    null
                )
                true
            }
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}
