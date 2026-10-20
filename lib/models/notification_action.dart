/// Representa un botón de acción interactivo dentro de la notificación
class NotificationAction {
  final String id;
  final String label;
  final bool requiresInput; // Habilita campo de texto directo en la notificación (RemoteInput)
  final String? iconAsset;
  final String? inputPlaceholder;

  const NotificationAction({
    required this.id,
    required this.label,
    this.requiresInput = false,
    this.iconAsset,
    this.inputPlaceholder = "Escribe una respuesta...",
  });

  /// Convierte la acción a un mapa JSON para comunicación con plataformas nativas
  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'requiresInput': requiresInput,
        'iconAsset': iconAsset,
        'inputPlaceholder': inputPlaceholder,
      };

  /// Fábrica para reconstruir la acción desde un mapa JSON
  factory NotificationAction.fromJson(Map<String, dynamic> json) {
    return NotificationAction(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      requiresInput: json['requiresInput'] ?? false,
      iconAsset: json['iconAsset'],
      inputPlaceholder: json['inputPlaceholder'] ?? "Escribe una respuesta...",
    );
  }

  NotificationAction copyWith({
    String? id,
    String? label,
    bool? requiresInput,
    String? iconAsset,
    String? inputPlaceholder,
  }) {
    return NotificationAction(
      id: id ?? this.id,
      label: label ?? this.label,
      requiresInput: requiresInput ?? this.requiresInput,
      iconAsset: iconAsset ?? this.iconAsset,
      inputPlaceholder: inputPlaceholder ?? this.inputPlaceholder,
    );
  }
}