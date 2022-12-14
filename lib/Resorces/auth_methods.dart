
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:instagramclone/Resorces/storage_method.dart';
import '../Models/users.dart';

class AuthMethod{
  //creating instance of FirebaseAuth Class
  final FirebaseAuth _auth=FirebaseAuth.instance;
  //creating instance of FirebaseFirestore
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;

  //getting documentSnapshot and returning users
  Future<Users> getUserDetails() async{
    //getting current user User data is provide by firebase
    User currentUser=_auth.currentUser!;

    DocumentSnapshot snap=await _firestore.collection('users').doc(currentUser.uid).get();
    return Users.fromSnap(snap);
  }


  //SignUp User
  Future<String> signUpUser({
    required String username,
    required String email,
    required String password,
    required String bio,
    required Uint8List file,
  })async{
    String res="Some error occured";
    try{
      if(username.isNotEmpty || email.isNotEmpty || password.isNotEmpty || bio.isNotEmpty || file!=null){
        print(file);
        //register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);

        //getting the uid of the user 
        String userId=cred.user!.uid;
        print(userId);

        //adding image to storage
        String photoUrl=await StorageMethod().uploadImageToStorage('profilePics', file, false);
        print(photoUrl);

        //add user to Firebase Firestore
        Users user=Users(
          email:email,
          username:username,
          bio:bio,
          uid:userId,
          following:[],
          followers:[],
          photoUrl:photoUrl,
        );
        await _firestore.collection('users').doc(userId).set(user.tojson());
        res="success";
      }
    }catch(err){
      res=err.toString();
    }
    return res;
  }

  //LoginUp user
  Future<String> loginUpUser({
    required String email,
    required String password,
  })async{
    String res="Some error occured";
    try{
      if(email.isNotEmpty || password.isNotEmpty){
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        res="success";
      }
      else{
        res="Check email and password properly";
      }

    }catch(err){
      res=err.toString();
    }
    return res;
  }
}