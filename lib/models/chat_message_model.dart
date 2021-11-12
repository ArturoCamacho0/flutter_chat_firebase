import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  ChatModel(
      {required this.id, required this.userIds, required this.lastMessage});

  factory ChatModel.fromFireStore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data as Map<String, dynamic>;

    return ChatModel(
        id: doc.id,
        userIds: data['users'] ?? <dynamic>[],
        lastMessage: data['lastMessage'] ?? <dynamic>{});
  }

  String id;
  List<dynamic> userIds;
  Map<dynamic, dynamic> lastMessage;
}

class Message {
  Message(
      {required this.id,
      required this.content,
      required this.idFrom,
      required this.idTo,
      required this.timestamp});

  factory Message.fromFireStore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data as Map<String, dynamic>;

    return Message(
        id: doc.id,
        content: data['content'],
        idFrom: data['idFrom'],
        idTo: data['idTo'],
        timestamp: data['timestamp']);
  }

  String id;
  String content;
  String idFrom;
  String idTo;
  DateTime timestamp;
}
