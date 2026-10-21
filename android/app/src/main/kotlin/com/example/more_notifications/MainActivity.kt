package com.example.more_notifications

import android.Manifest
import android.app.NotificationManager
import android.app.PendingIntent
import android.widget.RemoteViews
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
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
    private data class NotificationData(
        val channelId: String,
        val title: String,
        val body: String,
        val style: String,
        val color: Int,
        val useCustomBackground: Boolean,
        val lines: List<String>,
    )

    private var pendingNotification: NotificationData? = null
    private var pendingNotificationResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "showNotification") {
                val args = call.arguments as? Map<*, *>
                val channelId = args?.get("channelId") as? String ?: "chat_channel"
                val title = args?.get("title") as? String ?: "Nuevo mensaje"
                val body = args?.get("body") as? String ?: ""
                val style = args?.get("style") as? String ?: "chat"
                val color = (args?.get("color") as? Number)?.toInt() ?: 0xFF176B5B.toInt()
                val useCustomBackground = args?.get("useCustomBackground") as? Boolean ?: false
                val lines = (args?.get("lines") as? List<*>)?.mapNotNull { it as? String } ?: emptyList()
                val notification = NotificationData(
                    channelId,
                    title,
                    body,
                    style,
                    color,
                    useCustomBackground,
                    lines,
                )

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                    checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
                ) {
                    pendingNotification = notification
                    pendingNotificationResult = result
                    requestPermissions(
                        arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                        notificationPermissionRequestCode
                    )
                } else {
                    result.success(postNotification(notification))
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
            result.success(granted && postNotification(notification))
        }
    }

    private fun postNotification(data: NotificationData): Boolean {
        val (channelName, channelDescription) = when (data.style) {
            "reminder" -> "Recordatorios" to "Avisos y tareas pendientes"
            "alert" -> "Alertas" to "Avisos importantes del sistema"
            "digest" -> "Novedades" to "Resúmenes y novedades"
            "status" -> "Actualizaciones" to "Cambios en el estado de tus servicios"
            else -> "Chats" to "Mensajes de conversaciones"
        }
        NotificationChannelHelper.createDynamicChannel(
            this,
            data.channelId,
            channelName,
            channelDescription,
        )

        val notificationId = System.currentTimeMillis().toInt()
        val builder = NotificationCompat.Builder(this, data.channelId)
            .setContentTitle(data.title)
            .setContentText(data.body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
        if (data.useCustomBackground) {
            builder
                .setColor(data.color)
                .setLargeIcon(createAccentIcon(data.color, data.style))
        }

        when (data.style) {
            "reminder" -> {
                builder
                    .setSmallIcon(android.R.drawable.ic_menu_my_calendar)
                    .setCategory(NotificationCompat.CATEGORY_EVENT)
                    .setStyle(if (data.useCustomBackground) null else
                        NotificationCompat.BigTextStyle()
                            .setBigContentTitle(data.title)
                            .bigText(data.body),
                    )
                    .addAction(
                        android.R.drawable.ic_menu_close_clear_cancel,
                        "Hecho",
                        notificationAction("ACTION_DISMISS", notificationId),
                    )
            }
            "alert" -> {
                builder
                    .setSmallIcon(android.R.drawable.ic_dialog_alert)
                    .setCategory(NotificationCompat.CATEGORY_ALARM)
                    .setStyle(if (data.useCustomBackground) null else
                        NotificationCompat.BigTextStyle()
                            .setBigContentTitle(data.title)
                            .bigText(data.body),
                    )
                    .addAction(
                        android.R.drawable.ic_menu_view,
                        "Ver estado",
                        openAppAction(),
                    )
            }
            "digest" -> {
                val inboxStyle = if (data.useCustomBackground) null else {
                    NotificationCompat.InboxStyle()
                        .setBigContentTitle(data.title)
                        .setSummaryText("${data.lines.size} novedades")
                        .also { style -> data.lines.forEach(style::addLine) }
                }
                builder
                    .setSmallIcon(android.R.drawable.ic_menu_info_details)
                    .setCategory(NotificationCompat.CATEGORY_SOCIAL)
                    .setStyle(inboxStyle)
                    .addAction(
                        android.R.drawable.ic_menu_view,
                        "Leer",
                        openAppAction(),
                    )
            }
            "status" -> {
                builder
                    .setSmallIcon(android.R.drawable.ic_popup_sync)
                    .setCategory(NotificationCompat.CATEGORY_STATUS)
                    .setStyle(if (data.useCustomBackground) null else
                        NotificationCompat.BigTextStyle()
                            .setBigContentTitle(data.title)
                            .bigText(data.body),
                    )
            }
            else -> {
                val userPerson = Person.Builder().setName("Tú").build()
                val senderPerson = Person.Builder().setName(data.title).build()
                val messagingStyle = NotificationCompat.MessagingStyle(userPerson)
                    .setConversationTitle("Conversación Activa")
                    .setGroupConversation(true)
                    .addMessage(data.body, System.currentTimeMillis(), senderPerson)
                val remoteInput = RemoteInput.Builder(KEY_TEXT_REPLY)
                    .setLabel("Escribe una respuesta...")
                    .build()
                val replyIntent = Intent(this, NotificationReceiver::class.java).apply {
                    action = "ACTION_REPLY"
                    putExtra("notification_id", notificationId)
                }
                val replyPendingIntent = PendingIntent.getBroadcast(
                    this,
                    notificationId,
                    replyIntent,
                    PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
                )
                val replyAction = NotificationCompat.Action.Builder(
                    android.R.drawable.ic_menu_send,
                    "Responder",
                    replyPendingIntent,
                ).addRemoteInput(remoteInput).build()
                builder
                    .setSmallIcon(android.R.drawable.ic_dialog_email)
                    .setCategory(NotificationCompat.CATEGORY_MESSAGE)
                    .setStyle(if (data.useCustomBackground) null else messagingStyle)
                    .addAction(replyAction)
            }
        }

        if (data.useCustomBackground) {
            builder
                .setStyle(NotificationCompat.DecoratedCustomViewStyle())
                .setCustomContentView(createCustomContentView(data, expanded = false))
                .setCustomBigContentView(createCustomContentView(data, expanded = true))
        }

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(notificationId, builder.build())
        return true
    }

    private fun createCustomContentView(data: NotificationData, expanded: Boolean): RemoteViews {
        val layoutId = if (expanded) {
            R.layout.notification_custom_expanded
        } else {
            R.layout.notification_custom_collapsed
        }
        val views = RemoteViews(packageName, layoutId)
        val textColor = if (Color.luminance(data.color) > 0.45f) Color.BLACK else Color.WHITE

        views.setInt(R.id.notification_custom_root, "setBackgroundColor", data.color)
        views.setTextColor(R.id.notification_custom_title, textColor)
        views.setTextColor(R.id.notification_custom_body, textColor)
        views.setTextViewText(R.id.notification_custom_title, data.title)
        views.setTextViewText(R.id.notification_custom_body, data.body)
        if (expanded) {
            views.setTextColor(R.id.notification_custom_lines, textColor)
            views.setTextViewText(
                R.id.notification_custom_lines,
                data.lines.joinToString(separator = "\n") { "• $it" },
            )
        }
        return views
    }

    private fun createAccentIcon(color: Int, style: String): Bitmap {
        val size = 128
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val circlePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            this.color = color
            this.style = Paint.Style.FILL
        }
        canvas.drawCircle(size / 2f, size / 2f, size / 2f, circlePaint)

        val glyph = when (style) {
            "reminder" -> "R"
            "alert" -> "!"
            "digest" -> "N"
            "status" -> "S"
            else -> "M"
        }
        val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            this.color = android.graphics.Color.WHITE
            textSize = 68f
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            textAlign = Paint.Align.CENTER
        }
        val baseline = size / 2f - (textPaint.ascent() + textPaint.descent()) / 2f
        canvas.drawText(glyph, size / 2f, baseline, textPaint)
        return bitmap
    }

    private fun notificationAction(action: String, notificationId: Int): PendingIntent {
        val intent = Intent(this, NotificationReceiver::class.java).apply {
            this.action = action
            putExtra("notification_id", notificationId)
        }
        return PendingIntent.getBroadcast(
            this,
            notificationId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun openAppAction(): PendingIntent {
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        return PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}