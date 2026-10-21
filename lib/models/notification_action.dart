class NotificationAction {
  const NotificationAction({
    required this.id,
    required this.label,
    this.requiresInput = false,
    this.inputPlaceholder = 'Escribe una respuesta...',
    this.cancelNotification = false,
  });

  final String id;
  final String label;
  final bool requiresInput;
  final String inputPlaceholder;
  final bool cancelNotification;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'requiresInput': requiresInput,
        'inputPlaceholder': inputPlaceholder,
        'cancelNotification': cancelNotification,
      };

  factory NotificationAction.fromJson(Map<String, dynamic> json) => NotificationAction(
        id: json['id'] as String? ?? '',
        label: json['label'] as String? ?? '',
        requiresInput: json['requiresInput'] as bool? ?? false,
        inputPlaceholder: json['inputPlaceholder'] as String? ?? 'Escribe una respuesta...',
        cancelNotification: json['cancelNotification'] as bool? ?? false,
      );
}