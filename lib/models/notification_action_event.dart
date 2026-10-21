class NotificationActionEvent {
  const NotificationActionEvent({
    required this.notificationId,
    required this.actionId,
    this.userResponse,
    this.extras = const {},
  });

  final int notificationId;
  final String actionId;
  final String? userResponse;
  final Map<String, dynamic> extras;

  factory NotificationActionEvent.fromMap(Map<Object?, Object?> map) {
    return NotificationActionEvent(
      notificationId: (map['notificationId'] as num?)?.toInt() ?? 0,
      actionId: map['actionId'] as String? ?? '',
      userResponse: map['userResponse'] as String?,
      extras: (map['extras'] as Map<Object?, Object?>? ?? const {}).cast<String, dynamic>(),
    );
  }
}