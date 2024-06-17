import 'package:chat_app/widgets/message_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {

  void handlingPushNotifications() async {
    final firebaseCloudMesssaging = await FirebaseMessaging.instance;
    await firebaseCloudMesssaging.requestPermission();        //requesting user permissions

    firebaseCloudMesssaging.subscribeToTopic('chatmsg');
    // final deviceToken = await firebaseCloudMesssaging.getToken();        //device address on which the app is running
    // print(deviceToken);
  }


  @override
  void initState() {       //dont user async await for initState
    super.initState();
    //i want to ask user permission to send push notifications
    handlingPushNotifications();
  }



  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    //we set up a listener for the chat collection so when a new doc is added to this collection, we rebuild the ui
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            //chatsnapshot is the object that gives us access to the data that was loaded from the backend
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No messages found'),
            );
          }

          if (chatSnapshot.hasError) {
            return const Center(
              child: Text('Something went wrong...'),
            );
          }
          final loadedMessages = chatSnapshot.data!.docs;
          return ListView.builder(
              padding: const EdgeInsets.only(bottom: 40, right: 13, left: 13),
              reverse: true,
              itemCount: loadedMessages.length,
              itemBuilder: (context, index) {
                //return
                // Text(
                //   loadedMessages[index].data()['chatMessage'],
                //   style: const TextStyle(color: Colors.black),
                // );
                final chatMessage = loadedMessages[index].data(); //particular document and .data() gives us access to the map within that document
                final nextChatMessage = index + 1 < loadedMessages.length
                    ? loadedMessages[index + 1].data()
                    : null; //if next msg exists then index+1 must be less than list length and we assign the doc map to it

                final currentMessageUserId = chatMessage['userId'];
                final nextMessageUserId = nextChatMessage!=null ? nextChatMessage['userId'] : null;

                if (currentMessageUserId == nextMessageUserId) {
                  return MessageBubble.next(
                      message: chatMessage['chatMessage'],
                      isMe: authenticatedUser.uid == nextMessageUserId);
                } else {
                  return MessageBubble.first(
                      userImage: chatMessage['userProfilePic'],
                      username: chatMessage['userName'],
                      message: chatMessage['chatMessage'],
                      isMe: authenticatedUser.uid == currentMessageUserId);
                }
              });
        });
  }
}
