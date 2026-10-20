package com.example.more_notifications

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build

object NotificationChannelHelper {

    fun createDynamicChannel(
        context: Context,
        channelId: String,
        channelName: String,
        channelDescription: String = "Notificaciones de chats y mensajes"
    ) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val importance = NotificationManager.IMPORTANCE_HIGH
            
            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = channelDescription
                enableVibration(true)
                setShowBadge(true)
                enableLights(true)
            }

            val notificationManager = 
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            
            notificationManager.createNotificationChannel(channel)
        }
    }
}