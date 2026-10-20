package com.example.more_notifications

import android.Manifest
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.Person
import androidx.core.app.RemoteInput
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.more_notifications/core"
    private val KEY_TEXT_REPLY = "key_text_reply"
    private val notificationPermissionRequestCode = 2001
    private var pendingNotification: Triple<String, String, String>? = null
    private var pendingNotificationResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "showNotification") {
                val args = call.arguments as? Map<*, *>
                val channelId = args?.get("channelId") as? String ?: "chat_channel"
                val title = args?.get("title") as? String ?: "Nuevo mensaje"
                val body = args?.get("body") as? String ?: ""

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                    checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
                ) {
                    pendingNotification = Triple(channelId, title, body)
                    pendingNotificationResult = result
                    requestPermissions(
                        arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                        notificationPermissionRequestCode
                    )
                } else {
                    result.success(postNotification(channelId, title, body))
                }
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != notificationPermissionRequestCode) return

        val notification = pendingNotification
        val result = pendingNotificationResult
        pendingNotification = null
        pendingNotificationResult = null

        val granted = grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED
        if (notification != null && result != null) {
            result.success(
                granted && postNotification(notification.first, notification.second, notification.third)
            )
        }
    }

    private fun postNotification(channelId: String, title: String, body: String): Boolean {
        NotificationChannelHelper.createDynamicChannel(this, channelId, "Canal de Chats")

        val userPerson = Person.Builder().setName("Tú").build()
        val senderPerson = Person.Builder().setName(title).build()
        val messagingStyle = NotificationCompat.MessagingStyle(userPerson)
            .setConversationTitle("Conversación Activa")
            .setGroupConversation(true)
            .addMessage(body, System.currentTimeMillis(), senderPerson)

        val remoteInput = RemoteInput.Builder(KEY_TEXT_REPLY)
            .setLabel("Escribe una respuesta...")
            .build()
        val replyIntent = Intent(this, NotificationReceiver::class.java).apply {
            action = "ACTION_REPLY"
        }
        val replyPendingIntent = PendingIntent.getBroadcast(
            this,
            System.currentTimeMillis().toInt(),
            replyIntent,
            PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        val replyAction = NotificationCompat.Action.Builder(
            android.R.drawable.ic_menu_send, "Responder", replyPendingIntent
        ).addRemoteInput(remoteInput).build()
        val notification = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(android.R.drawable.ic_dialog_email)
            .setStyle(messagingStyle)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .addAction(replyAction)
            .build()

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(System.currentTimeMillis().toInt(), notification)
        return true
    }
}