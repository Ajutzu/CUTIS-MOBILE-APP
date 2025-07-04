import 'api.dart';

class ConversationService {
  ConversationService._();
  static final _dio = Api().dio;

  Future<List<dynamic>> getAllConversations() async {
    final res = await _dio.get('/api/conversations');
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> createConversation(String title) async {
    final res = await _dio.post('/api/conversations', data: {'title': title});
    return res.data as Map<String, dynamic>;
  }
}
