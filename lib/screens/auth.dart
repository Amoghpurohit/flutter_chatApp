import 'dart:io';

import 'package:chat_app/widgets/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';


final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var isLoggedIn = true;
  var isAuthenticating = false;
  

  File? userPickedProfileImage;

  //controllers and dispose methods are not requied for TextFormFields(Form Widget)

  final _formKey = GlobalKey<FormState>();  //this variable can be final as key wont change

  var enteredEmail = '';
  var enteredUsername = '';
  var enteredPassword = '';

  void _onSubmit() async {

    var isValidated = _formKey.currentState!.validate();
    if(!isValidated || !isLoggedIn && userPickedProfileImage == null){
      setState(() {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please take a Profile Pic')));
      });
      return;
    }

    _formKey.currentState!.save();

    try{
      setState(() {
        isAuthenticating = true;
      });
    if(isLoggedIn){                      //for login flow
      final userCredentials = await _firebase.signInWithEmailAndPassword(email: enteredEmail, password: enteredPassword);
      //print(userCredentials);
    }else{                            //sign up flow
      final userCredentials = await _firebase.createUserWithEmailAndPassword(email: enteredEmail, password: enteredPassword); //using firebase SDK to send http requests to firebase
      //print(userCredentials); //this method is provided by firebase SDK and helps us handle exceptions
      // as we are using firebaseAuth Exceptions to handle already in use email, invalid emails, weak passwords etc
      //we must ensure that we are using try catch blocks to handle and display error msgs around the http requests

      //store the picked image on firebase
      final storageRef = FirebaseStorage.instance.ref().child('userImages').child('${userCredentials.user!.uid}.jpg'); //a path for storing images is created andthe images are named according to the user's uid
      final uploadingImage = await storageRef.putFile(userPickedProfileImage!);      //putting the image inside the path(Upload Task)
      final imageUrl = await storageRef.getDownloadURL();    //getting the image URL for future reference(so next time we can pull from db if we want to display this image again somewhere)
      print(imageUrl);
      FirebaseFirestore.instance.collection('users').doc(userCredentials.user!.uid).set(   //storing user specific data using firestore
        {
          'username': enteredUsername,
          'email': enteredEmail,        
          'profilePic': imageUrl,
        }
      );
      }
    }
    on FirebaseAuthException catch(error){
      setState(() {
      isAuthenticating = false;
      });
      if(mounted){                             //mounted basically checks if the same screen is on the stack or the screen has changed
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message ?? 'Authentication failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SingleChildScrollView(
              child: SizedBox(
                height: 150,
                width: 150,
                child: Image.asset('assets/images/chat.png'),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 30), //adding space between cardand edge of screen
              child: SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24
                          ), //adding space between card and inner text or content
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if(!isLoggedIn) UserImagePicker(
                              onUserPicksProfilePic: (image){
                                userPickedProfileImage = image;
                              },
                            ),
                            TextFormField(               //use TextFormField to validate the inputs
                              //controller: ,
                              validator: (value){   //value hereis the entered value coule be null as well(String?)
                                if(value == null || value.trim().isEmpty || !value.contains('@gmail.com')){
                                  return "Please Enter a Valid Email Address";
                                }
                                return null;
                              },  
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                              ),
                              autocorrect: false,
                              keyboardType: TextInputType.emailAddress,
                              textCapitalization: TextCapitalization.none,
                              onSaved: (value){
                                enteredEmail = value!;
                              },
                            ),
                            TextFormField(
                              //minLines: 6,
                              decoration:
                                  const InputDecoration(labelText: 'Password'),
                              obscureText: true,
                              validator: (value){
                                if(value == null || value.trim().isEmpty){
                                  return "This Field is Mandatory";
                                }else if(RegExp(r'[A-Z]').allMatches(value).isEmpty){
                                  return "Please Use a UpperCase Character in your Password";
                                }else if(value.length < 6){
                                  return "Password should be minimum of 6 characters";
                                }
                                return null;
                              },
                              onSaved: (value){
                                enteredPassword = value!;
                              },
                            ),
                            if(!isLoggedIn) TextFormField(
                              validator: (value){
                                if(value == null || value.isEmpty || value.trim().length < 4){
                                  return 'Please enter a valid username of 4 or more characters';
                                }else{
                                  return null;
                                }
                              },
                              onSaved: (value){
                                enteredUsername = value!;
                              },
                              decoration: const InputDecoration(labelText: 'Username'),keyboardType: TextInputType.name,),
                            const SizedBox(
                              height: 5,
                            ),
                            if(isAuthenticating) const CircularProgressIndicator(),
                            if(!isAuthenticating)
                            ElevatedButton(
                              onPressed: _onSubmit,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer),
                              child: Text(isLoggedIn ? 'Login' : 'Sign Up'),
                            ),
                            if(!isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                isLoggedIn = !isLoggedIn;  //
                              });
                              },
                              child:
                                  Text(isLoggedIn ? 'Dont have an Account? Sign Up' : 'I already have an Account!'),
                            ),
                          ],
                        ),
                      ))),
            ),
          ],
        ),
      ),
    );
  }
}
