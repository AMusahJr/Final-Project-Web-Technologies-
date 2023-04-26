import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram_flutter/resources/storage_methods.dart';
import 'package:instagram_flutter/models/user.dart' as model;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User>getUserDetails() async{
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot = await _firestore.collection('users').doc(currentUser.uid).get();


    return model.User.fromSnap(documentSnapshot);
  }

  // sign up user
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String studentID,
    required String yeargroup,
    required String major,
    required String dob,
    required String residenceStatus,
    required String bestfood,
    required String bestmovie,
    required Uint8List file,
  }) async {
    String res = "Some error occured";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          studentID.isNotEmpty ||
          yeargroup.isNotEmpty ||
          major.isNotEmpty ||
          dob.isNotEmpty ||
          residenceStatus.isNotEmpty ||
          bestfood.isNotEmpty ||
          bestmovie.isNotEmpty ||
          file != null) {
        // register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

       

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        // add user to our database



        model.User _user = model.User(
          username: username,
          uid: cred.user!.uid,
          email: email,
          studentID: studentID,
          yeargroup: yeargroup,
          major: major,
          dob: dob,
          residenceStatus: residenceStatus,
          bestfood: bestfood,
          bestmovie: bestmovie,
          followers: [],
          following: [],
          photoUrl: photoUrl,

        );
        await _firestore.collection('users').doc(cred.user!.uid).set(_user.toJson());

        res = "success";
      }
    else {
      res = "Please enter all fields";
    }
     }catch (err) {
      return err.toString();
    }
    return res;
  }

  //logging in user
  Future<String> loginUser({
    required String email,
    required String password
  }) async{
    String res = 'Some error occured';

    try {
      if(email.isNotEmpty|| password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email, 
          password: password,
          );
        res = 'Success';
      } else {
        res = "Please enter in all fields";
      }

    } 
     catch(err) {
      err.toString();

    }
    return res;
  }
  Future<void>signOut() async{
     await _auth.signOut();
  }
   
  

   
}
