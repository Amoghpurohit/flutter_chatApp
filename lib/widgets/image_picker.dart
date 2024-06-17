import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onUserPicksProfilePic});

  final void Function(File file) onUserPicksProfilePic;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {

  File? userPickedImage;


  Future<void> _pickImage() async {                       //image will be picked sometime in the future hence its type
    final pickedImage = await ImagePicker().pickImage(    //will have to wait for the image to be picked
      source: ImageSource.camera,                         //pickImage yields a XFile and wants a Image source, we can set that using the ImageSouce enum class - camera, gallery, values
      imageQuality: 50, maxWidth: 150, 
      //preferredCameraDevice: CameraDevice.rear
      );
    
    if(pickedImage == null){           //the image could not be picekd as well
      return;
    }

    setState(() {
      userPickedImage = File(pickedImage.path);        //creating a file object using the picked image's path and calling setstate as we want to display this image using FileImage
    },);

    widget.onUserPicksProfilePic(userPickedImage!);    //execute the function with the picked image so that the data is sent to auth screen along with the form
      
    
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage: userPickedImage !=null ? FileImage(userPickedImage!) : null,  //FileImage returns a ImageProvider while File.network or File.asset returns a Widget
        ),
        TextButton.icon(onPressed: _pickImage       //passing a reference to the func as we want to pick a image when the button is pressed and not execute this func when the widget tree is built
        , label: const Text('Add Profile Picture'), icon: const Icon(Icons.image),), 
      ],
    );
  }
}