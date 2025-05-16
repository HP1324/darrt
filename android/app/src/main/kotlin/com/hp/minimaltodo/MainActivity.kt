package com.hp.minimaltodo  // Make sure this matches your app's package name

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import androidx.annotation.NonNull

class MainActivity: FlutterActivity() {
    private val BATTERY_CHANNEL = "com.hp.minimaltodo/battery_settings"
    private val PDF_CHANNEL = "com.hp.minimaltodo/pdf_saver"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(
            flutterEngine
        )

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            BATTERY_CHANNEL
        )
            .setMethodCallHandler { call, result ->
                if (call.method == "openBatterySettings") {
                    try {
                        val intent =
                            Intent()
                        intent.action =
                            Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS
                        startActivity(
                            intent
                        )
                        result.success(
                            null
                        )
                    } catch (e: Exception) {
                        result.error(
                            "ERROR",
                            e.message,
                            null
                        )
                    }
                } else {
                    result.notImplemented()
                }
            }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PDF_CHANNEL
        )
            .setMethodCallHandler { call, result ->
                if (call.method == "savePdfToDownloads") {
                    val filename =
                        call.argument<String>(
                            "filename"
                        )
                            ?: "note.pdf"
                    val bytes =
                        call.argument<ByteArray>(
                            "bytes"
                        )
                    if (bytes != null) {
                        try {
                            val resolver =
                                contentResolver
                            val contentValues =
                                android.content.ContentValues()
                                    .apply {
                                        put(
                                            android.provider.MediaStore.MediaColumns.DISPLAY_NAME,
                                            filename
                                        )
                                        put(
                                            android.provider.MediaStore.MediaColumns.MIME_TYPE,
                                            "application/pdf"
                                        )
                                        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
                                            put(
                                                android.provider.MediaStore.MediaColumns.RELATIVE_PATH,
                                                android.os.Environment.DIRECTORY_DOWNLOADS
                                            )
                                        }
                                    }

                            val uri =
                                resolver.insert(
                                    android.provider.MediaStore.Downloads.EXTERNAL_CONTENT_URI,
                                    contentValues
                                )
                            if (uri != null) {
                                val outputStream =
                                    resolver.openOutputStream(
                                        uri
                                    )
                                outputStream?.write(
                                    bytes
                                )
                                outputStream?.close()
                                result.success(
                                    "success"
                                )
                            } else {
                                result.error(
                                    "URI_ERROR",
                                    "Could not create MediaStore entry",
                                    null
                                )
                            }
                        } catch (e: Exception) {
                            result.error(
                                "SAVE_ERROR",
                                e.message,
                                null
                            )
                        }
                    } else {
                        result.error(
                            "ARGUMENT_ERROR",
                            "Bytes are null",
                            null
                        )
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}