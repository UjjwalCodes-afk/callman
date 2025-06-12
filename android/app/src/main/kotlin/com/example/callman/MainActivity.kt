package com.example.callman

import android.media.MediaRecorder
import android.os.Environment
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    private var recorder: MediaRecorder? = null
    private var output: String? = null
    private val CHANNEL = "com.yourapp.call_recorder"

    override fun configureFlutterEngine(@NonNull engine: FlutterEngine) {
        super.configureFlutterEngine(engine)

        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, res ->
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
    }

private fun startRecording() {
    try {
        val dir = File(getExternalFilesDir(Environment.DIRECTORY_MUSIC), "CallRecordings")
        if (!dir.exists()) dir.mkdirs()

        val outputFile = File(dir, "call_${System.currentTimeMillis()}.m4a")
        output = outputFile.absolutePath

        recorder = MediaRecorder()

        recorder?.apply {
            setAudioSource(MediaRecorder.AudioSource.VOICE_COMMUNICATION) // 👈 correct source
            setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
            setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
            setOutputFile(output)

            // 👇 Key step: Call prepare() before start()
            prepare()

            // 👇 Now start recording
            start()

            println("🎙 Recording started. Output: $output")
        }

    } catch (e: Exception) {
        e.printStackTrace()
        println("❌ Failed to start recording: ${e.message}")
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
        recorder = null

        output?.also {
            println("🎙 Recording saved at $it")
        }
    } catch (e: Exception) {
        e.printStackTrace()
        println("❌ Failed to stop recording: ${e.message}")
        null
    }
}


}
