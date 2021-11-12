import 'package:chat/screens/chat_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;

// ignore: must_be_immutable
class ConversationList extends StatefulWidget {
  const ConversationList({
    Key? key,
  }) : super(key: key);
  @override
  _ConversationListState createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  var firebase = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  getUser() {
    final User? user = auth.currentUser;
    String id = user!.uid.toString();

    return id;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: SingleChildScrollView(
            physics: const ScrollPhysics(),
            child: StreamBuilder<QuerySnapshot>(
                stream: firebase
                    .collection('messages')
                    .doc(getUser().toString())
                    .collection('messages')
                    .orderBy("date", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      itemCount: snapshot.data!.docs.isNotEmpty
                          ? snapshot.data!.docs.length
                          : 0,
                      itemBuilder: (context, i) {
                        QueryDocumentSnapshot x = snapshot.data!.docs[i];
                        return BuildItem(
                          toName: x['toName'].toString(),
                          receiver: x['to'],
                          content: x['content'].toString(),
                          date: x['date'].toDate().toString(),
                          read: x['read'],
                        );
                      },
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                })));
  }
}

class BuildItem extends StatelessWidget {
  final String toName, receiver, content, date;
  final bool read;
  BuildItem(
      {Key? key,
      required this.toName,
      required this.receiver,
      required this.date,
      required this.content,
      required this.read})
      : super(key: key);
  final FirebaseAuth auth = FirebaseAuth.instance;
  var firebase = FirebaseFirestore.instance;

  getUser() {
    final User? user = auth.currentUser;
    String id = user!.uid.toString();

    return id;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Map<String, dynamic> data = <String, dynamic>{"read": true};
        firebase
            .collection('messages')
            .doc(getUser().toString())
            .collection('messages')
            .doc(receiver)
            .update(data);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ChatDetail(id: receiver.toString(), name: toName.toString());
        }));
      },
      child: Container(
        color: !read ? Colors.blueGrey.shade50 : Colors.white,
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.red.shade100,
                    child: Text(toName[0]),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            toName,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Text(
                            content,
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: !read
                                    ? FontWeight.bold
                                    : FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              timeago.format(DateTime.parse(date), locale: 'es'),
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: !read ? FontWeight.bold : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
