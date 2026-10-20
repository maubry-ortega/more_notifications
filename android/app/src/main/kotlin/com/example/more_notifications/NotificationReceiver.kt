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
        if (intent.action == "ACTION_REPLY") {
            // 1. Extraemos el texto que el usuario escribió en la notificación
            val remoteInputResults: Bundle? = RemoteInput.getResultsFromIntent(intent)
            val replyText = remoteInputResults?.getCharSequence(KEY_TEXT_REPLY)?.toString()

            if (!replyText.isNullOrEmpty()) {
                // Muestra un aviso visual rápido o procesa el mensaje
                Toast.makeText(context, "Respuesta recibida: $replyText", Toast.LENGTH_SHORT).show()
                
                // TODO: Aquí puedes enviar 'replyText' hacia Dart mediante un Background Channel o guardarlo localmente.
            }

            // 2. Cerramos/Cancelamos la notificación automáticamente al responder
            // (Si le pasaste un ID único por Intent puedes recuperarlo, o usar un ID genérico/estático)
            val notificationId = intent.getIntExtra("notification_id", 101)
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.cancel(notificationId)
        }
    }
}