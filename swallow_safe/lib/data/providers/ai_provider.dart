import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/chat_message.dart';

/// Abstract AI provider interface
abstract class AIProvider {
  Future<String> chat({
    required String systemPrompt,
    required List<ChatMessage> messages,
    required String userMessage,
  });
}

/// Dual AI Provider supporting both OpenAI and Anthropic
class DualAIProvider implements AIProvider {
  // TODO: Replace with your actual API endpoint (Cloud Function proxy)
  static const String _proxyBaseUrl = 'https://your-firebase-project.cloudfunctions.net';
  
  // Current provider selection
  AIProviderType _currentProvider = AIProviderType.openai;
  
  AIProviderType get currentProvider => _currentProvider;
  
  void setProvider(AIProviderType provider) {
    _currentProvider = provider;
  }
  
  @override
  Future<String> chat({
    required String systemPrompt,
    required List<ChatMessage> messages,
    required String userMessage,
  }) async {
    switch (_currentProvider) {
      case AIProviderType.openai:
        return _chatOpenAI(systemPrompt, messages, userMessage);
      case AIProviderType.anthropic:
        return _chatAnthropic(systemPrompt, messages, userMessage);
    }
  }
  
  Future<String> _chatOpenAI(
    String systemPrompt,
    List<ChatMessage> messages,
    String userMessage,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_proxyBaseUrl/aiProxy'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'provider': 'openai',
          'model': 'gpt-4o',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            ...messages.map((m) => m.toApiFormat()),
            {'role': 'user', 'content': userMessage},
          ],
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] as String? ?? 'No response received.';
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  Future<String> _chatAnthropic(
    String systemPrompt,
    List<ChatMessage> messages,
    String userMessage,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_proxyBaseUrl/aiProxy'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'provider': 'anthropic',
          'model': 'claude-3-5-sonnet-20241022',
          'system': systemPrompt,
          'messages': [
            ...messages.map((m) => m.toApiFormat()),
            {'role': 'user', 'content': userMessage},
          ],
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] as String? ?? 'No response received.';
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

/// Mock AI provider for development/testing
class MockAIProvider implements AIProvider {
  @override
  Future<String> chat({
    required String systemPrompt,
    required List<ChatMessage> messages,
    required String userMessage,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Return contextual mock responses
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('exercise') || lowerMessage.contains('chin tuck')) {
      return '''The Chin Tuck exercise is excellent for strengthening the muscles used in swallowing. 

Here's how to do it properly:
1. Sit or stand with good posture
2. Slowly lower your chin toward your chest
3. Hold for 3-5 seconds
4. Return to the starting position
5. Repeat as directed by your therapist

This exercise helps protect your airway during swallowing. Keep up the great work!''';
    }
    
    if (lowerMessage.contains('pain') || lowerMessage.contains('hurt')) {
      return '''I understand you're experiencing some discomfort. This is common during recovery, but it's important to monitor.

A few suggestions:
- Take breaks between exercise sets if needed
- Stay hydrated with small sips of water
- Report persistent pain to your healthcare provider

If the pain is severe or sudden, please contact your doctor right away.''';
    }
    
    if (lowerMessage.contains('progress') || lowerMessage.contains('better')) {
      return '''Recovery takes time, and every small step matters! Based on the exercises in your program, you're building the muscle strength and coordination needed for safer swallowing.

Remember:
- Consistency is more important than intensity
- Track your symptoms daily to see patterns
- Celebrate your streak achievements

You're doing great by staying committed to your exercises!''';
    }
    
    return '''Thank you for your question! I'm here to help with your swallowing exercises and recovery journey.

I can assist with:
- Exercise technique and modifications
- Understanding your program
- Tracking tips and motivation
- General recovery information

What would you like to know more about?''';
  }
}

enum AIProviderType {
  openai,
  anthropic,
}
