package com.example.callman

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.MediaRecorder
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.AlarmClock
import android.provider.Settings
import android.widget.Toast
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.*
import com.example.overlay.FloatingService

class MainActivity : FlutterActivity() {

    private var recorder: MediaRecorder? = null
    private var output: String? = null

    private val RECORD_CHANNEL   = "com.yourapp.call_recorder"
    private val OVERLAY_CHANNEL  = "overlay_channel"
    private val REMINDER_CHANNEL = "com.example.reminder"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 🎙 Call recording
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

        // 🧊 Overlay
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, OVERLAY_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "showOverlay") {
                val name = call.argument<String>("callerName") ?: "Unknown"
                val number = call.argument<String>("callerNumber") ?: "Unknown"

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
                    val overlayIntent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName"))
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

        // ⏰ Reminder / Alarm Clock
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, REMINDER_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleReminder" -> {
                    val id = call.argument<Int>("id") ?: 0
                    val title = call.argument<String>("title") ?: "Reminder"
                    val body = call.argument<String>("body") ?: ""
                    val timeMillis = call.argument<Long>("epochMillis") ?: 0L
                    scheduleReminder(id, title, body, timeMillis, result)
                }

                "setSystemAlarm" -> {
                    val hour = call.argument<Int>("hour") ?: 0
                    val minute = call.argument<Int>("minute") ?: 0
                    val message = call.argument<String>("message") ?: ""
                    val skipUi = call.argument<Boolean>("skipUi") ?: false

                    val intent = Intent(AlarmClock.ACTION_SET_ALARM).apply {
                        putExtra(AlarmClock.EXTRA_HOUR, hour)
                        putExtra(AlarmClock.EXTRA_MINUTES, minute)
                        putExtra(AlarmClock.EXTRA_MESSAGE, message)
                        putExtra(AlarmClock.EXTRA_SKIP_UI, skipUi)
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }

                    startActivity(intent)
                    result.success("Alarm Set")
                }

                else -> result.notImplemented()
            }
        }
    }

    // 🎙 Call recording helpers
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
            println("🎙 Recording started → $output")
        } catch (e: Exception) {
            e.printStackTrace()
            recorder?.release()
            recorder = null
            output = null
        }
    }

    private fun stopRecording(): String? =
        try {
            recorder?.apply { stop(); release() }
            val saved = output
            recorder = null
            output = null
            saved
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }

    // ⏰ Reminder using AlarmManager
    private fun scheduleReminder(id: Int, title: String, body: String, timeMillis: Long, result: MethodChannel.Result) {
        if (!checkExactAlarmPermission(applicationContext)) {
            requestExactAlarmPermission(applicationContext)
            result.error("EXACT_ALARM_PERMISSION_DENIED", "User has not granted exact alarm permission", null)
            return
        }

        val intent = Intent(applicationContext, ReminderReceiver::class.java).apply {
            putExtra("title", title)
            putExtra("body", body)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            applicationContext,
            id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            timeMillis,
            pendingIntent
        )

        Toast.makeText(applicationContext, "Reminder scheduled!", Toast.LENGTH_SHORT).show()
        println("⏰ Reminder set for: ${Date(timeMillis)} (id=$id)")
        result.success(true)
    }

    private fun checkExactAlarmPermission(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            alarmManager.canScheduleExactAlarms()
        } else true
    }

    private fun requestExactAlarmPermission(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                data = Uri.parse("package:" + context.packageName)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
        }
    }
}
