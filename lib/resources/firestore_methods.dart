import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_flutter/models/post.dart';
import 'package:instagram_flutter/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //upload post
  Future<String> uploadPost(
    String description,
    String username,
    String profImage,
    Uint8List file,
    String uid,
  ) async {
   
    String res = "some error occurred";
    try{
        String photoUrl = await StorageMethods().uploadImageToStorage('posts', file, true);

        String postId = const Uuid().v1();
        Post post = Post(
          description: description,
          uid: uid,
          username: username,
          postId: postId,
          datePublished: DateTime.now(),
          postUrl: photoUrl,
          profImage: profImage,
          likes: [],
            );

            _firestore.collection('posts').doc(postId).set(
              post.toJson(),
              );
            res = "success";
            } catch (err) {
              res = err.toString();

    }
    return res;
  }

  Future<String>likePost(String postId, String uid, List likes) async{
    String res = "Some error occurred";
    try{
      if(likes.contains(uid)) {
        _firestore.collection('posts').doc(postId).update({
          'likes':FieldValue.arrayRemove([uid]),
        });

      } else {
        _firestore.collection('posts').doc(postId).update({
          'likes':FieldValue.arrayUnion([uid]),
        });
      }
      res = 'Success';
    } catch(err) {
      res = err.toString();
    }
    return res;
  }

  //post comment

  Future<String>postComment(String postId, String text, String uid, String name, String profilePic) async{
    String res = 'Some error occurred';
    try{
      if(text.isNotEmpty) {
        String commentId = const Uuid().v1();
        _firestore.collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .set({
          'profilePic':profilePic,
          'name':name,
          'uuid':uid,
          'text':text,
          'commentId':commentId,
          'date Published':DateTime.now(),
        });
        res = 'Success';
      } else{
        res = "Please enter text";
      }

    }catch(err) {
      res = err.toString();
    }
    return res;

  }  

  // deleting post
  Future<String>deletePost(String postId) async {
    String res = "Some error occurred";
    try{
        await _firestore.collection('posts').doc(postId).delete();
        res = 'success';
    } catch(err) {
      res = err.toString();

    }
    return res;
  } 
  Future<void>followUser(
    String uid,
    String followId
  ) async{
    try{
      DocumentSnapshot snap = await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if(following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers':FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following':FieldValue.arrayRemove([followId])
        });


      } else{
        await _firestore.collection('users').doc(followId).update({
          'followers':FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following':FieldValue.arrayUnion([followId])
        });
      }
      
    } catch(e) {
      print(e.toString());
    }
  }
}