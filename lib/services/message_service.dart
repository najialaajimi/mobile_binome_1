import 'dart:convert';
import '../models/message.dart';
import 'storage_service.dart';

class MessageService {
  static const _conversationsKey = 'conversations';
  static const _seededKey = 'messages_seeded';

  final StorageService _storage = StorageService.instance;

  String _messagesKey(String convId) => 'messages_$convId';

  Future<void> init() async {
    if (_storage.getBool(_seededKey) != true) {
      await _seedMessages();
      await _storage.setBool(_seededKey, true);
    }
  }

  Future<void> _seedMessages() async {
    final now = DateTime.now();

    const conv1Id = 'conv_1';
    const conv2Id = 'conv_2';

    final conversations = [
      Conversation(
        id: conv1Id,
        participants: ['tenant_1', 'owner_1'],
        lastMessage: 'Bonjour, est-ce que le logement est toujours disponible ?',
        lastMessageAt: now.subtract(const Duration(hours: 2)),
        unreadCount: 1,
      ),
      Conversation(
        id: conv2Id,
        participants: ['tenant_2', 'owner_2'],
        lastMessage: 'Oui, vous pouvez visiter samedi matin.',
        lastMessageAt: now.subtract(const Duration(days: 1)),
        unreadCount: 0,
      ),
    ];

    final convEncoded =
        conversations.map((c) => jsonEncode(c.toJson())).toList();
    await _storage.setStringList(_conversationsKey, convEncoded);

    final messages1 = [
      Message(
        id: 'msg_1',
        conversationId: conv1Id,
        senderId: 'tenant_1',
        receiverId: 'owner_1',
        content: 'Bonjour, est-ce que le logement est toujours disponible ?',
        sentAt: now.subtract(const Duration(hours: 3)),
        isRead: true,
      ),
      Message(
        id: 'msg_2',
        conversationId: conv1Id,
        senderId: 'owner_1',
        receiverId: 'tenant_1',
        content: 'Bonjour ! Oui, il est toujours disponible. Souhaitez-vous visiter ?',
        sentAt: now.subtract(const Duration(hours: 2, minutes: 30)),
        isRead: true,
      ),
      Message(
        id: 'msg_3',
        conversationId: conv1Id,
        senderId: 'tenant_1',
        receiverId: 'owner_1',
        content: 'Oui, je suis disponible ce weekend, est-ce possible ?',
        sentAt: now.subtract(const Duration(hours: 2)),
        isRead: false,
      ),
    ];

    final messages2 = [
      Message(
        id: 'msg_4',
        conversationId: conv2Id,
        senderId: 'tenant_2',
        receiverId: 'owner_2',
        content: 'Bonjour, je souhaiterais visiter votre maison à Marseille.',
        sentAt: now.subtract(const Duration(days: 1, hours: 3)),
        isRead: true,
      ),
      Message(
        id: 'msg_5',
        conversationId: conv2Id,
        senderId: 'owner_2',
        receiverId: 'tenant_2',
        content: 'Oui, vous pouvez visiter samedi matin.',
        sentAt: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];

    await _storage.setStringList(
        _messagesKey(conv1Id), messages1.map((m) => jsonEncode(m.toJson())).toList());
    await _storage.setStringList(
        _messagesKey(conv2Id), messages2.map((m) => jsonEncode(m.toJson())).toList());
  }

  List<Conversation> _getAllConversations() {
    final list = _storage.getStringList(_conversationsKey) ?? [];
    return list
        .map((s) => Conversation.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveConversations(List<Conversation> convs) async {
    final encoded = convs.map((c) => jsonEncode(c.toJson())).toList();
    await _storage.setStringList(_conversationsKey, encoded);
  }

  List<Conversation> getConversations(String userId) => _getAllConversations()
      .where((c) => c.participants.contains(userId))
      .toList()
    ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

  List<Message> getMessages(String conversationId) {
    final list = _storage.getStringList(_messagesKey(conversationId)) ?? [];
    return list
        .map((s) => Message.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
  }

  Future<void> sendMessage(Message message) async {
    final messages = getMessages(message.conversationId);
    messages.add(message);
    await _storage.setStringList(
        _messagesKey(message.conversationId),
        messages.map((m) => jsonEncode(m.toJson())).toList());

    // Update conversation
    final convs = _getAllConversations();
    final idx = convs.indexWhere((c) => c.id == message.conversationId);
    if (idx >= 0) {
      final old = convs[idx];
      convs[idx] = old.copyWith(
        lastMessage: message.content,
        lastMessageAt: message.sentAt,
        unreadCount: old.unreadCount + 1,
      );
      await _saveConversations(convs);
    }
  }

  Future<void> markAsRead(String conversationId, String userId) async {
    final messages = getMessages(conversationId);
    final updated = messages.map((m) {
      if (m.receiverId == userId && !m.isRead) {
        return m.copyWith(isRead: true);
      }
      return m;
    }).toList();
    await _storage.setStringList(
        _messagesKey(conversationId),
        updated.map((m) => jsonEncode(m.toJson())).toList());

    final convs = _getAllConversations();
    final idx = convs.indexWhere((c) => c.id == conversationId);
    if (idx >= 0) {
      convs[idx] = convs[idx].copyWith(unreadCount: 0);
      await _saveConversations(convs);
    }
  }

  Future<Conversation> createConversation(
      String userId1, String userId2) async {
    final convs = _getAllConversations();
    // Check if exists
    try {
      return convs.firstWhere((c) =>
          c.participants.contains(userId1) && c.participants.contains(userId2));
    } catch (_) {
      // Create new
      final conv = Conversation(
        id: 'conv_${DateTime.now().millisecondsSinceEpoch}',
        participants: [userId1, userId2],
        lastMessage: '',
        lastMessageAt: DateTime.now(),
        unreadCount: 0,
      );
      convs.add(conv);
      await _saveConversations(convs);
      return conv;
    }
  }
}
