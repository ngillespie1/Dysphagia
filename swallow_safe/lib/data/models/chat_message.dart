import 'package:equatable/equatable.dart';

/// Chat message for AI Recovery Assistant
class ChatMessage extends Equatable {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isLoading;
  
  const ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isLoading = false,
  });
  
  /// Create a user message
  factory ChatMessage.user({
    required String id,
    required String content,
  }) {
    return ChatMessage(
      id: id,
      content: content,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );
  }
  
  /// Create an assistant message
  factory ChatMessage.assistant({
    required String id,
    required String content,
    bool isLoading = false,
  }) {
    return ChatMessage(
      id: id,
      content: content,
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
      isLoading: isLoading,
    );
  }
  
  /// Create from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      role: MessageRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => MessageRole.user,
      ),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  /// Format for API request
  Map<String, String> toApiFormat() {
    return {
      'role': role == MessageRole.user ? 'user' : 'assistant',
      'content': content,
    };
  }
  
  ChatMessage copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    bool? isLoading,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }
  
  @override
  List<Object?> get props => [id, content, role, timestamp, isLoading];
}

/// Message role in conversation
enum MessageRole {
  user,
  assistant,
  system,
}
