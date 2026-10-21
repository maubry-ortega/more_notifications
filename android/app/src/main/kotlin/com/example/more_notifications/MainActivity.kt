package com.example.more_notifications

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
import android.os.Build
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.app.Person
import androidx.core.app.RemoteInput
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private val methodChannelName = "com.example.more_notifications/core"
    private val eventChannelName = "com.example.more_notifications/actions"
    private val notificationPermissionRequestCode = 2001
    private var pendingNotification: Map<String, Any?>? = null
    private var pendingNotificationResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, eventChannelName)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    actionSink = events
                    drainPendingActions().forEach(events::success)
                }

                override fun onCancel(arguments: Any?) {
                    actionSink = null
                }
            })

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "initialize" -> result.success(drainPendingActions())
                    "showNotification" -> {
                        val arguments = call.arguments as? Map<*, *>
                        if (arguments == null) {
                            result.error("INVALID_PAYLOAD", "Notification payload must be a map", null)
                            return@setMethodCallHandler
                        }
                        val payload = arguments.entries.associate { (key, value) -> key.toString() to value }
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
                        ) {
                            pendingNotification = payload
                            pendingNotificationResult = result
                            requestPermissions(
                                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                                notificationPermissionRequestCode,
                            )
                        } else {
                            result.success(postNotification(payload))
                        }
                    }
                    "cancelNotification" -> {
                        val id = (call.argument<Number>("id"))?.toInt()
                        if (id != null) notificationManager().cancel(id)
                        result.success(null)
                    }
                    "cancelAllNotifications" -> {
                        notificationManager().cancelAll()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != notificationPermissionRequestCode) return

        val payload = pendingNotification
        val result = pendingNotificationResult
        pendingNotification = null
        pendingNotificationResult = null
        val granted = grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED
        if (payload != null && result != null) {
            result.success(granted && postNotification(payload))
        }
    }

    private fun postNotification(payload: Map<String, Any?>): Boolean {
        val id = (payload["id"] as? Number)?.toInt() ?: 0
        val title = payload["title"] as? String ?: ""
        val body = payload["body"] as? String ?: ""
        val channelId = payload["channelId"] as? String ?: "default_notifications"
        val channelName = payload["channelName"] as? String ?: "Notificaciones"
        val style = payload["style"] as? Map<*, *> ?: emptyMap<String, Any>()
        val styleType = style["type"] as? String ?: "basic"
        val color = (payload["color"] as? Number)?.toInt()
        val useCustomBackground = payload["useCustomBackground"] as? Boolean ?: false
        val actions = (payload["actions"] as? List<*>)
            ?.mapNotNull { it as? Map<*, *> }
            ?: emptyList()
        val extras = payload["extras"] as? Map<*, *> ?: emptyMap<String, Any>()

        createChannel(channelId, channelName)
        val builder = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(openAppIntent())

        if (color != null) builder.setColor(color)

        when (styleType) {
            "bigText" -> builder.setStyle(
                NotificationCompat.BigTextStyle().bigText(style["text"] as? String ?: body),
            )
            "inbox" -> {
                val inbox = NotificationCompat.InboxStyle().setBigContentTitle(title)
                (style["lines"] as? List<*>)?.filterIsInstance<String>()?.forEach(inbox::addLine)
                builder.setStyle(inbox)
            }
            "messaging" -> {
                val person = Person.Builder().setName(title).build()
                val messaging = NotificationCompat.MessagingStyle(Person.Builder().setName("Tú").build())
                    .setConversationTitle(style["conversationTitle"] as? String ?: title)
                    .setGroupConversation(style["isGroupChat"] as? Boolean ?: false)
                (style["messages"] as? List<*>)?.filterIsInstance<Map<*, *>>()?.forEach { message ->
                    messaging.addMessage(
                        message["text"] as? String ?: "",
                        System.currentTimeMillis(),
                        Person.Builder().setName(message["senderName"] as? String ?: title).build(),
                    )
                }
                if (style["messages"] == null) messaging.addMessage(body, System.currentTimeMillis(), person)
                builder.setCategory(NotificationCompat.CATEGORY_MESSAGE).setStyle(messaging)
            }
            "progress" -> builder.setProgress(
                (style["max"] as? Number)?.toInt() ?: 100,
                (style["progress"] as? Number)?.toInt() ?: 0,
                style["indeterminate"] as? Boolean ?: false,
            )
        }

        actions.forEachIndexed { index, action ->
            val actionId = action["id"] as? String ?: "action_$index"
            val label = action["label"] as? String ?: actionId
            val requiresInput = action["requiresInput"] as? Boolean ?: false
            val intent = Intent(this, NotificationReceiver::class.java).apply {
                this.action = "com.example.more_notifications.ACTION"
                putExtra("notification_id", id)
                putExtra("action_id", actionId)
                putExtra("cancel_notification", action["cancelNotification"] as? Boolean ?: false)
                putExtra("extras_json", JSONObject(extras.entries.associate { it.key.toString() to it.value }).toString())
            }
            val pendingIntent = PendingIntent.getBroadcast(
                this,
                id * 100 + index,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or
                    if (requiresInput) PendingIntent.FLAG_MUTABLE else PendingIntent.FLAG_IMMUTABLE,
            )
            val actionBuilder = NotificationCompat.Action.Builder(
                if (requiresInput) android.R.drawable.ic_menu_send else android.R.drawable.ic_menu_view,
                label,
                pendingIntent,
            )
            if (requiresInput) {
                val inputKey = "input_$actionId"
                actionBuilder.addRemoteInput(
                    RemoteInput.Builder(inputKey)
                        .setLabel(action["inputPlaceholder"] as? String ?: "Escribe una respuesta...")
                        .build(),
                )
            }
            builder.addAction(actionBuilder.build())
        }

        if (useCustomBackground && color != null) {
            builder
                .setStyle(NotificationCompat.DecoratedCustomViewStyle())
                .setCustomContentView(customRemoteView(title, body, color, false, style))
                .setCustomBigContentView(customRemoteView(title, body, color, true, style))
        }

        notificationManager().notify(id, builder.build())
        return true
    }

    private fun createChannel(channelId: String, channelName: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                channelName,
                NotificationManager.IMPORTANCE_HIGH,
            )
            notificationManager().createNotificationChannel(channel)
        }
    }

    private fun customRemoteView(
        title: String,
        body: String,
        color: Int,
        expanded: Boolean,
        style: Map<*, *>,
    ): RemoteViews {
        val layout = if (expanded) R.layout.notification_custom_expanded else R.layout.notification_custom_collapsed
        val views = RemoteViews(packageName, layout)
        val textColor = if (Color.luminance(color) > 0.45f) Color.BLACK else Color.WHITE
        views.setInt(R.id.notification_custom_root, "setBackgroundColor", color)
        views.setTextColor(R.id.notification_custom_title, textColor)
        views.setTextColor(R.id.notification_custom_body, textColor)
        views.setTextViewText(R.id.notification_custom_title, title)
        views.setTextViewText(R.id.notification_custom_body, body)
        if (expanded) {
            val lines = (style["lines"] as? List<*>)
                ?.filterIsInstance<String>()
                ?.joinToString(separator = "\n") { "• $it" }
                .orEmpty()
            views.setTextViewText(R.id.notification_custom_lines, lines)
            views.setTextColor(R.id.notification_custom_lines, textColor)
        }
        return views
    }

    private fun openAppIntent(): PendingIntent {
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

    private fun notificationManager() = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    private fun drainPendingActions(): List<Map<String, Any?>> {
        val preferences = getSharedPreferences("notification_core", Context.MODE_PRIVATE)
        val queue = JSONArray(preferences.getString("pending_actions", "[]"))
        val actions = mutableListOf<Map<String, Any?>>()
        for (index in 0 until queue.length()) {
            val item = queue.optJSONObject(index) ?: continue
            actions.add(
                mapOf(
                    "notificationId" to item.optInt("notificationId"),
                    "actionId" to item.optString("actionId"),
                    "userResponse" to item.optString("userResponse").takeIf(String::isNotEmpty),
                    "extras" to item.optJSONObject("extras")?.let(::jsonObjectMap).orEmpty(),
                ),
            )
        }
        preferences.edit().remove("pending_actions").apply()
        return actions
    }

    private fun jsonObjectMap(json: JSONObject): Map<String, Any?> =
        json.keys().asSequence().associateWith { key -> json.opt(key) }

    companion object {
        @Volatile
        private var actionSink: EventChannel.EventSink? = null

        fun deliverAction(context: Context, action: Map<String, Any?>) {
            val sink = actionSink
            if (sink != null) {
                sink.success(action)
                return
            }
            val preferences = context.getSharedPreferences("notification_core", Context.MODE_PRIVATE)
            val queue = JSONArray(preferences.getString("pending_actions", "[]"))
            val item = JSONObject().apply {
                put("notificationId", action["notificationId"])
                put("actionId", action["actionId"])
                put("userResponse", action["userResponse"])
                put("extras", JSONObject(action["extras"] as? Map<*, *> ?: emptyMap<String, Any>()))
            }
            queue.put(item)
            preferences.edit().putString("pending_actions", queue.toString()).apply()
        }
    }
}