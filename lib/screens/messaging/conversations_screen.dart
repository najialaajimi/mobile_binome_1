import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/message.dart';
import '../../services/message_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../widgets/empty_state.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final _messageService = MessageService();
  final _authService = AuthService();

  List<Conversation> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() {
    final userId = _authService.getCurrentUser()?.id ?? '';
    setState(() {
      _conversations = _messageService.getConversations(userId);
    });
  }

  String _getOtherUserName(Conversation conv) {
    final currentUserId = _authService.getCurrentUser()?.id ?? '';
    final otherId =
        conv.participants.firstWhere((p) => p != currentUserId,
            orElse: () => '');
    final users = _authService.getAllUsers();
    final otherList = users.where((u) => u.id == otherId).toList();
    return otherList.isNotEmpty ? otherList.first.fullName : 'Inconnu';
  }

  String _getOtherUserInitials(Conversation conv) {
    final currentUserId = _authService.getCurrentUser()?.id ?? '';
    final otherId =
        conv.participants.firstWhere((p) => p != currentUserId,
            orElse: () => '');
    final users = _authService.getAllUsers();
    final otherList = users.where((u) => u.id == otherId).toList();
    return otherList.isNotEmpty ? otherList.first.initials : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: _conversations.isEmpty
          ? const EmptyState(
              icon: Icons.message_outlined,
              title: 'Aucun message',
              message: 'Vous n\'avez pas encore de conversations.',
            )
          : ListView.builder(
              itemCount: _conversations.length,
              itemBuilder: (_, i) {
                final conv = _conversations[i];
                final name = _getOtherUserName(conv);
                final initials = _getOtherUserInitials(conv);
                final timeFormat = DateFormat('HH:mm');

                return ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            AppColors.primary.withAlpha(20),
                        child: Text(
                          initials,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (conv.unreadCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${conv.unreadCount}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                      fontWeight: conv.unreadCount > 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    conv.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: conv.unreadCount > 0
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: conv.unreadCount > 0
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: Text(
                    timeFormat.format(conv.lastMessageAt),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.chat,
                      arguments: {
                        'conversationId': conv.id,
                        'otherUserName': name,
                      },
                    ).then((_) => _loadConversations());
                  },
                );
              },
            ),
    );
  }
}
