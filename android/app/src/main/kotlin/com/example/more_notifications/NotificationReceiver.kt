package com.example.more_notifications

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.core.app.RemoteInput
import android.widget.Toast

class NotificationReceiver : BroadcastReceiver() {

    companion object {
        const val KEY_TEXT_REPLY = "key_text_reply"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val notificationId = intent.getIntExtra("notification_id", 101)

        when (intent.action) {
            "ACTION_REPLY" -> {
                val remoteInputResults: Bundle? = RemoteInput.getResultsFromIntent(intent)
                val replyText = remoteInputResults?.getCharSequence(KEY_TEXT_REPLY)?.toString()
                if (!replyText.isNullOrEmpty()) {
                    Toast.makeText(context, "Respuesta recibida: $replyText", Toast.LENGTH_SHORT).show()
                }
                notificationManager.cancel(notificationId)
            }
            "ACTION_DISMISS" -> notificationManager.cancel(notificationId)
        }
    }
}