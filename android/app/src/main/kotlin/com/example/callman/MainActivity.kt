package com.example.callman

import android.content.Intent
import android.media.MediaRecorder
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import com.example.overlay.FloatingService

class MainActivity : FlutterActivity() {

    private var recorder: MediaRecorder? = null
    private var output: String? = null
    private val RECORD_CHANNEL = "com.yourapp.call_recorder"
    private val OVERLAY_CHANNEL = "overlay_channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 🎙 Call Recording Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, RECORD_CHANNEL).setMethodCallHandler { call, res ->
            when (call.method) {
                "startRecording" -> {
                    startRecording()
                    res.success(null)
                }
                "stopRecording" -> {
                    val recordedPath = stopRecording()
                    res.success(recordedPath)
                }
                else -> res.notImplemented()
            }
        }

        // 🧊 Overlay Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, OVERLAY_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "showOverlay") {
                val name: String = call.argument("callerName") ?: "Unknown"
                val number: String = call.argument("callerNumber") ?: "Unknown"

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
                    val overlayIntent = Intent(
                        Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:$packageName")
                    )
                    startActivity(overlayIntent)
                } else {
                    val intent = Intent(this, FloatingService::class.java).apply {
                        putExtra("callerName", name)
                        putExtra("callerNumber", number)
                    }

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(intent)
                    } else {
                        startService(intent)
                    }
                }

                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    // ✅ Move startRecording OUTSIDE the configureFlutterEngine
    private fun startRecording() {
        try {
            val dir = File(getExternalFilesDir(Environment.DIRECTORY_MUSIC), "CallRecordings")
            if (!dir.exists()) dir.mkdirs()

            val outputFile = File(dir, "call_${System.currentTimeMillis()}.m4a")
            output = outputFile.absolutePath

            recorder = MediaRecorder().apply {
                setAudioSource(MediaRecorder.AudioSource.VOICE_COMMUNICATION)
                setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                setOutputFile(output)
                prepare()
                start()
            }

            println("🎙 Recording started. Output: $output")
        } catch (e: Exception) {
            e.printStackTrace()
            recorder?.release()
            recorder = null
            output = null
        }
    }

    private fun stopRecording(): String? {
        return try {
            recorder?.apply {
                stop()
                release()
            }
            val savedPath = output
            recorder = null
            output = null
            savedPath
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
}
