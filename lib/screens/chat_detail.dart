import 'package:chat/models/chat_message_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';

class ChatDetail extends StatefulWidget {
  const ChatDetail({Key? key, required this.id, required this.name})
      : super(key: key);
  final String id, name;

  @override
  _ChatDetailState createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final firebase = FirebaseFirestore.instance;
  TextEditingController message = TextEditingController();

  String userName = "";

  getUser() {
    final User? user = auth.currentUser;
    String id = user!.uid.toString();

    return id;
  }

  send() async {
    if (message.text.isNotEmpty) {
      try {
        String content = message.text;
        message.clear();
        await firebase
            .collection("messages")
            .doc(getUser().toString())
            .collection("messages")
            .doc(widget.id)
            .collection("messages")
            .doc()
            .set({'date': DateTime.now(), 'content': content, 'type': "send"});

        await firebase
            .collection("messages")
            .doc(getUser().toString())
            .collection("messages")
            .doc(widget.id)
            .set({
          "content": content,
          "date": DateTime.now(),
          "read": true,
          "to": widget.id,
          "toName": widget.name
        });

        await firebase
            .collection("messages")
            .doc(widget.id)
            .collection("messages")
            .doc(getUser().toString())
            .collection("messages")
            .doc()
            .set(
                {'date': DateTime.now(), 'content': content, 'type': "recive"});

        var data = {
          "content": content,
          "date": DateTime.now(),
          "read": false,
          "to": getUser().toString(),
          "toName": userName
        };

        await firebase
            .collection("messages")
            .doc(widget.id)
            .collection("messages")
            .doc(getUser().toString())
            .set(data)
            .onError((error, stackTrace) => print(error));
      } catch (e) {
        print(e);
      }
    }
  }

  getUserName() async {
    String name = await firebase
        .collection('users')
        .doc(getUser().toString())
        .get()
        .then((value) {
      userName = value.data()!['name'].toString();
      return userName;
    });

    print(userName);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getUserName();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  width: 2,
                ),
                CircleAvatar(
                  backgroundColor: Colors.red.shade100,
                  child: Text(widget.name[0]),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        widget.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        "Online",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.settings,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
              stream: firebase
                  .collection("messages")
                  .doc(getUser().toString())
                  .collection("messages")
                  .doc(widget.id)
                  .collection("messages")
                  .orderBy("date")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.isNotEmpty
                        ? snapshot.data!.docs.length
                        : 0,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 10, bottom: 70),
                    itemBuilder: (context, i) {
                      QueryDocumentSnapshot x = snapshot.data!.docs[i];
                      return Container(
                        padding: const EdgeInsets.only(
                            left: 14, right: 14, top: 10, bottom: 10),
                        child: Align(
                          alignment: (x['type'] == "send"
                              ? Alignment.topRight
                              : Alignment.topLeft),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: (x['type'] == "send"
                                  ? Colors.red[200]
                                  : Colors.grey.shade200),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              x['content'],
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextField(
                      controller: message,
                      decoration: const InputDecoration(
                          hintText: "Escribe un mesaje...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      send();
                    },
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                    backgroundColor: Colors.redAccent,
                    elevation: 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
