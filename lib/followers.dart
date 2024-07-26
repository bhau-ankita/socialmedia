import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> followUser(String userIdToFollow) async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    var currentUserDoc =
        FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
    var userToFollowDoc =
        FirebaseFirestore.instance.collection('users').doc(userIdToFollow);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot currentUserSnapshot =
          await transaction.get(currentUserDoc);
      DocumentSnapshot userToFollowSnapshot =
          await transaction.get(userToFollowDoc);

      if (!currentUserSnapshot.exists || !userToFollowSnapshot.exists) {
        throw Exception('User does not exist');
      }

      List<dynamic> following = currentUserSnapshot['following'] ?? [];
      if (!following.contains(userIdToFollow)) {
        following.add(userIdToFollow);
        transaction.update(currentUserDoc, {'following': following});
      }

      List<dynamic> followers = userToFollowSnapshot['followers'] ?? [];
      if (!followers.contains(currentUser.uid)) {
        followers.add(currentUser.uid);
        transaction.update(userToFollowDoc, {'followers': followers});
      }
    });
  }
}

Future<void> unfollowUser(String userIdToUnfollow) async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    var currentUserDoc =
        FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
    var userToUnfollowDoc =
        FirebaseFirestore.instance.collection('users').doc(userIdToUnfollow);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot currentUserSnapshot =
          await transaction.get(currentUserDoc);
      DocumentSnapshot userToUnfollowSnapshot =
          await transaction.get(userToUnfollowDoc);

      if (!currentUserSnapshot.exists || !userToUnfollowSnapshot.exists) {
        throw Exception('User does not exist');
      }

      List<dynamic> following = currentUserSnapshot['following'] ?? [];
      if (following.contains(userIdToUnfollow)) {
        following.remove(userIdToUnfollow);
        transaction.update(currentUserDoc, {'following': following});
      }

      List<dynamic> followers = userToUnfollowSnapshot['followers'] ?? [];
      if (followers.contains(currentUser.uid)) {
        followers.remove(currentUser.uid);
        transaction.update(userToUnfollowDoc, {'followers': followers});
      }
    });
  }
}
