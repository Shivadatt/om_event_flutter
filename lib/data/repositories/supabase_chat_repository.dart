import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/helpers/supabase_mapper.dart';

class ChatRoom {
  final String id;
  final String name;
  final DateTime createdAt;

  ChatRoom({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json, String id) {
    return ChatRoom(
      id: id,
      name: json['name'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String message;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.message,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String id) {
    return ChatMessage(
      id: id,
      roomId: json['roomId'] ?? '',
      senderId: json['senderId'] ?? '',
      message: json['message'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'senderId': senderId,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Repository implementing real-time chat room messages on Supabase.
class SupabaseChatRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<ChatRoom>> getChatRooms() async {
    final response = await _client
        .from('chat_rooms')
        .select()
        .order('updated_at', ascending: false);
    
    return response
        .map((row) => ChatRoom.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
        .toList();
  }

  Future<void> createChatRoom(ChatRoom room) async {
    final payload = SupabaseMapper.toSnakeCase(room.toJson());
    await _client.from('chat_rooms').upsert({
      'id': room.id,
      ...payload,
    });
  }

  Future<List<ChatMessage>> getMessages(String roomId) async {
    final response = await _client
        .from('chat_messages')
        .select()
        .eq('room_id', roomId)
        .order('created_at', ascending: true);
    
    return response
        .map((row) => ChatMessage.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
        .toList();
  }

  Future<void> sendMessage(String roomId, String senderId, String message) async {
    final payload = {
      'room_id': roomId,
      'sender_id': senderId,
      'message': message,
      'created_at': DateTime.now().toIso8601String(),
    };
    await _client.from('chat_messages').insert(payload);
  }

  Stream<List<ChatMessage>> streamMessages(String roomId) {
    return _client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .map((rows) {
          final list = rows
              .map((row) => ChatMessage.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
              .toList();
          list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return list;
        });
  }
}
