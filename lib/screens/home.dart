import 'package:chat/screens/chat.dart';
import 'package:chat/screens/login.dart';
import 'package:chat/widgets/contacts.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentTabIndex = 0;
  final List<Widget> _myPage = <Widget>[const Chat(), const Contacts(), const Chat()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:PageView.builder(
        itemBuilder: (context, position) => _myPage[_currentTabIndex],
        itemCount: _myPage.length,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Contactos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: "Salir",
          ),
        ],
        onTap: _onTap,
        currentIndex: _currentTabIndex,
      ),
    );
  }

  _onTap(int tabIndex) {
    final _auth = FirebaseAuth.instance;
    switch (tabIndex) {
      case 0:
        break;
      case 1:
        break;
      case 2:
        try{
          _auth.signOut();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }catch(e){print(e);}
        break;
    }
    setState(() {
      _currentTabIndex = tabIndex;
    });
  }
}
