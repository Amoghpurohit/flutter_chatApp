import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_messages.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(onPressed: (){
            FirebaseAuth.instance.signOut();     //user token is removed and since we are listening to authStateChanges
          },                                       //data associated with snapshot is gone and firebase emits a new event without token hence Auth Screen will be shown
          icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.primary,))
        ],
      ),
      body: const Center(
        child: Column(
          children: [
            Expanded(child: ChatMessages()),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: NewChatMessages(),
            ),
          ],
        )
      ),
    );
  }
}