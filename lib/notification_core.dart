import 'dart:async';

import 'package:flutter/services.dart';

import 'models/notification_action_event.dart';
import 'models/notification_payload.dart';

class NotificationCoreEngine {
  NotificationCoreEngine._();

  static const MethodChannel _methodChannel =
      MethodChannel('com.example.more_notifications/core');
  static const EventChannel _eventChannel =
      EventChannel('com.example.more_notifications/actions');
  static StreamSubscription<dynamic>? _actionSubscription;
  static void Function(NotificationActionEvent event)? _actionHandler;
  static bool _initialized = false;

  static Future<void> initialize({
    void Function(NotificationActionEvent event)? onAction,
  }) async {
    _actionHandler = onAction;
    if (_initialized) return;

    _actionSubscription = _eventChannel.receiveBroadcastStream().listen((event) {
      final actionEvent = NotificationActionEvent.fromMap(
        Map<Object?, Object?>.from(event as Map),
      );
      _actionHandler?.call(actionEvent);
    });
    await _methodChannel.invokeMethod<List<dynamic>>('initialize');
    _initialized = true;
  }

  static Future<bool> show(NotificationPayload notification) async {
    _ensureInitialized();
    return await _methodChannel.invokeMethod<bool>(
          'showNotification',
          notification.toJson(),
        ) ??
        false;
  }

  static Future<void> cancel(int id) async {
    _ensureInitialized();
    await _methodChannel.invokeMethod<void>('cancelNotification', {'id': id});
  }

  static Future<void> cancelAll() async {
    _ensureInitialized();
    await _methodChannel.invokeMethod<void>('cancelAllNotifications');
  }

  static void onAction(void Function(NotificationActionEvent event) handler) {
    _ensureInitialized();
    _actionHandler = handler;
  }

  static Future<void> dispose() async {
    await _actionSubscription?.cancel();
    _actionSubscription = null;
    _actionHandler = null;
    _initialized = false;
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('Llama NotificationCoreEngine.initialize() antes de usar la biblioteca.');
    }
  }
}