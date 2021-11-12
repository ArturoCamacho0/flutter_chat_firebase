import 'package:chat/screens/chat_detail.dart';
import 'package:chat/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Este sera el widget que creara cada item de nuestra lista
class ContactsListItem extends StatelessWidget {
  final User user;

  ContactsListItem({required this.user}) : super(key: ObjectKey(user));

// Aqui tenemos a nuestro elemento de lista
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        user.name,
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ChatDetail(id: user.id, name: user.name);
        }));
      },
      leading: CircleAvatar(
        backgroundColor: Colors.red.shade100,
        child: Text(user.name[0]),
      ),
    );
  }
}

class User {
  User({required this.id, required this.name});

  factory User.fromMap(Map<String, dynamic> data) {
    return User(id: data['id'], name: data['name']);
  }

  final String id;
  final String name;
}

// Esta sera la clase principal que va a crear cada elemeto mandandole los productos al constructor
class Contacts extends StatelessWidget {
  const Contacts({Key? key}) : super(key: key);

  streamUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((QuerySnapshot list) => list.docs
            .map((DocumentSnapshot snap) => User.fromMap(snap.data as dynamic))
            .toList())
        .handleError((dynamic e) {
      // ignore: avoid_print
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    var firebase = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const Home()));
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  width: 2,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Text(
                        "Contactos",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: SingleChildScrollView(
          physics: const ScrollPhysics(),
          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    // Traemos los datos de la colección
                    itemCount:snapshot.data!.docs.isNotEmpty
                        ? snapshot.data!.docs.length
                        : 0,
                    itemBuilder: (context, i) {
                      QueryDocumentSnapshot x = snapshot.data!.docs[i];
                        if(auth.currentUser!.uid.toString() != x['user_id']){
                          return ContactsListItem(
                              user: User(name: x['name'], id: x['user_id']));
                        }else{
                          return Text("");
                        }
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
        ),
      ),
    );
  }
}
