import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewChatMessages extends StatefulWidget {
  const NewChatMessages({super.key});

  @override
  State<NewChatMessages> createState() => _NewChatMessagesState();
}

class _NewChatMessagesState extends State<NewChatMessages> {
  final messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void submitMessage() async {
    final enteredMessage = messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();     //after validation of the msg we are popping the keyboard and clearing the input from textField
    messageController.clear();

    final user = FirebaseAuth.instance.currentUser!;           //can access user as its a authenticated user hence we can get FirebaseAuth.globalinstance.current logged in user
    final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();     //now that we have access to the current user 
    //and its attributes so now we can get that user's data from the firebase firestore by giving the collection's path/folder 
    //and focusing on the current user by going into the user's doc(accessed by the uid which is auto generated by firebase).



    //send to firebase logic...
    FirebaseFirestore.instance.collection('chats').add({
      'userId':userData.id,
      'userName':userData.data()!['username'],        //userData now has user data which is a map and now .data() is a map from which we have to pass the keys to get the values
      'chatMessage':enteredMessage,
      'createdAt':Timestamp.now(),
      'userProfilePic':userData.data()!['profilePic'],   //this user data(username and profilePic) can be fetched from local as well
    });

  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Send a Message...',
            ),
            autocorrect: true,
            enableSuggestions: true,
            keyboardType: TextInputType.emailAddress,
            controller: messageController,
          ),
        ),
        IconButton(onPressed: submitMessage, icon: const Icon(Icons.send))
      ],
    );
  }
}