
import 'package:chat_app/screens/auth.dart';
import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/screens/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const App());
  
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 63, 17, 177)),
      ),
      home: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting) return const SplashScreen();
        // this splash screen is added to give time to firebase whilst its figuring out whether or not the toke exists for the user data provided
        if(snapshot.hasData) return const ChatScreen();  //if snapshot has data that means token was generated and valid user data was provided
        return const AuthScreen();
      })
    );
  }
} 

//once we are logged in we dont want to show the auth screen again if user opens the app (before token expiration)
//hence we can use StreamBuilder where stream is capcable of emitting multiple states and build the ui accordingly
//a token will be generated only if valid data is given and then auth state changes for the user, we are going to capture this and render UI
//and this token will stored on the device and managed by firebase since we are using firebase SDK.