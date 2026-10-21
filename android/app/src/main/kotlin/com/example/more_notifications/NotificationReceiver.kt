package com.example.more_notifications

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.core.app.RemoteInput
import org.json.JSONObject

class NotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val actionId = intent.getStringExtra("action_id") ?: return
        val notificationId = intent.getIntExtra("notification_id", 0)
        val userResponse = RemoteInput.getResultsFromIntent(intent)
            ?.getCharSequence("input_$actionId")
            ?.toString()
        val extras = runCatching {
            JSONObject(intent.getStringExtra("extras_json") ?: "{}")
                .let { json -> json.keys().asSequence().associateWith { key -> json.opt(key) } }
        }.getOrDefault(emptyMap())

        MainActivity.deliverAction(
            context,
            mapOf(
                "notificationId" to notificationId,
                "actionId" to actionId,
                "userResponse" to userResponse,
                "extras" to extras,
            ),
        )

        if (intent.getBooleanExtra("cancel_notification", false)) {
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.cancel(notificationId)
        }
    }
}