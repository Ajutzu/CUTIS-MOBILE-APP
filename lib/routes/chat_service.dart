import 'package:dio/dio.dart';
import 'api.dart';

/// Data model representing a chat message coming from the backend.
class ChatMessage {
  final String role; // 'user' or 'ai'
  final String content;

  ChatMessage({required this.role, required this.content});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}

/// Wrapper for `/api/conversation/start` response.
class StartConversationResponse {
  final String conversationId;
  final String reply;

  StartConversationResponse({required this.conversationId, required this.reply});

  factory StartConversationResponse.fromJson(Map<String, dynamic> json) {
    return StartConversationResponse(
      conversationId: json['conversationId'] as String,
      reply: json['reply'] as String,
    );
  }
}

/// Wrapper for `/api/conversation/latest` response.
class LatestConversationResponse {
  final String? id;
  final List<ChatMessage> messages;
  final Map<String, dynamic>? analysis;

  LatestConversationResponse({this.id, required this.messages, this.analysis});

  factory LatestConversationResponse.fromJson(Map<String, dynamic> json) {
    final convo = json['conversation'];
    if (convo == null) {
      return LatestConversationResponse(id: null, messages: const [], analysis: null);
    }
    return LatestConversationResponse(
      id: convo['id'] as String,
      messages: (convo['messages'] as List<dynamic>)
          .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      analysis: convo['analysis'] as Map<String, dynamic>?,
    );
  }
}

/// Service class that communicates with the conversation endpoints.
class ChatService {
  ChatService();

  Dio get _dio => Api().dio;

  /// Helper to standardise error handling similar to the TS implementation.
  Future<Map<String, dynamic>> _handleResponse(Response res) async {
    if (res.statusCode != null && res.statusCode! < 400) {
      return Map<String, dynamic>.from(res.data);
    }
    final data = res.data;
    final message = data is Map<String, dynamic>
        ? (data['message'] ?? data['error'] ?? 'Conversation request failed')
        : 'Conversation request failed';
    throw DioException(requestOptions: res.requestOptions, response: res, message: message);
  }

  /// POST `/api/conversation/start`
  /// If [historyId] is provided the conversation continues that medical history.
  Future<StartConversationResponse> startConversation({required String message, String? historyId}) async {
    await Api.init();
    final body = historyId != null ? {'message': message, 'historyId': historyId} : {'message': message};
    final res = await _dio.post('/api/conversation/start', data: body);
    final data = await _handleResponse(res);
    return StartConversationResponse.fromJson(data);
  }

  /// GET `/api/conversation/latest` – fetches latest conversation/messages.
  Future<LatestConversationResponse> getLatestConversation({String? historyId}) async {
    await Api.init();
    final query = historyId != null ? '?historyId=$historyId' : '';
    final res = await _dio.get('/api/conversation/latest$query');
    final data = await _handleResponse(res);
    return LatestConversationResponse.fromJson(data);
  }

  /// POST `/api/conversation/{conversationId}/reply` – send a follow-up message and get AI reply.
  Future<ReplyResponse> sendReply({
    required String conversationId,
    required String message,
    String? historyId,
  }) async {
    await Api.init();
    final body = historyId != null ? {'message': message, 'historyId': historyId} : {'message': message};
    final res = await _dio.post('/api/conversation/$conversationId/reply', data: body);
    final data = await _handleResponse(res);
    return ReplyResponse.fromJson(data);
  }
}

/// Simple model for reply endpoint response.
class ReplyResponse {
  final String reply;

  ReplyResponse({required this.reply});

  factory ReplyResponse.fromJson(Map<String, dynamic> json) => ReplyResponse(reply: json['reply'] as String);
}

