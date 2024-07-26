import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialmediaapp/homefeed.dart';
import 'package:socialmediaapp/userprofile.dart';

Future<int> _getFollowerCount(String userId) async {
  DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
  List<dynamic> followers = userDoc['followers'] ?? [];
  return followers.length;
}

Future<int> _getFollowingCount(String userId) async {
  DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
  List<dynamic> following = userDoc['following'] ?? [];
  return following.length;
}

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  Future<DocumentSnapshot?> _getUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
    } else {
      throw Exception("User not logged in");
    }
  }

  Stream<List<String>> _getUserPosts() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return FirebaseFirestore.instance
          .collection('posts')
          .where('user_id', isEqualTo: currentUser.uid)
          .snapshots()
          .map((querySnapshot) => querySnapshot.docs
              .map((doc) => doc['image_url'] as String)
              .toList());
    } else {
      throw Exception("User not logged in");
    }
  }

  Future<void> followUser(String userId) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentReference currentUserRef =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      DocumentReference targetUserRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      WriteBatch batch = FirebaseFirestore.instance.batch();

      batch.update(currentUserRef, {
        'following': FieldValue.arrayUnion([userId])
      });

      batch.update(targetUserRef, {
        'followers': FieldValue.arrayUnion([currentUser.uid])
      });

      try {
        await batch.commit();
      } catch (e) {
        print('Error following user: $e');
      }
    } else {
      throw Exception('User not logged in');
    }
  }

  Future<void> unfollowUser(String userId) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentReference currentUserRef =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      DocumentReference targetUserRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      WriteBatch batch = FirebaseFirestore.instance.batch();

      batch.update(currentUserRef, {
        'following': FieldValue.arrayRemove([userId])
      });

      batch.update(targetUserRef, {
        'followers': FieldValue.arrayRemove([currentUser.uid])
      });

      try {
        await batch.commit();
      } catch (e) {
        print('Error unfollowing user: $e');
      }
    } else {
      throw Exception('User not logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Homefeed()));
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot?>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData ||
              snapshot.data == null ||
              !snapshot.data!.exists) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CreateProfilePage()),
              );
            });
            return Container();
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>?;

          if (userData == null) {
            return Center(child: Text('User data is not available'));
          }

          User? currentUser = FirebaseAuth.instance.currentUser;
          bool isFollowing =
              userData['followers']?.contains(currentUser?.uid) ?? false;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50.0,
                  backgroundImage: userData['profile_image'] != null
                      ? NetworkImage(userData['profile_image'])
                      : AssetImage('assets/images/107.jpg') as ImageProvider,
                  backgroundColor: Colors.white,
                ),
                SizedBox(height: 20.0),
                Text(
                  userData['name'] ?? '',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.0),
                Text(
                  userData['bio'] ?? '',
                  style: TextStyle(fontSize: 16.0),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Followers',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        FutureBuilder<int>(
                          future: _getFollowerCount(
                              FirebaseAuth.instance.currentUser!.uid),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text('0');
                            }
                            return Text(
                              snapshot.data?.toString() ?? '0',
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'Following',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        FutureBuilder<int>(
                          future: _getFollowingCount(
                              FirebaseAuth.instance.currentUser!.uid),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text('0');
                            }
                            return Text(
                              snapshot.data?.toString() ?? '0',
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    if (currentUser != null) {
                      if (isFollowing) {
                        await unfollowUser(userData['uid']);
                      } else {
                        await followUser(userData['uid']);
                      }

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => AccountPage()),
                      );
                    }
                  },
                  child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                ),
                SizedBox(height: 20.0),
                Expanded(
                  child: StreamBuilder<List<String>>(
                    stream: _getUserPosts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data == null) {
                        return Center(child: Text('No posts available'));
                      }

                      List<String> posts = snapshot.data!;

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                        ),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            posts[index],
                            fit: BoxFit.cover,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
