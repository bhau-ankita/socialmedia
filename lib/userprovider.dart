import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _profileImageUrl = 'assets/avatar.png';

  String get profileImageUrl => _profileImageUrl;

  void updateProfileImage(String newImageUrl) {
    _profileImageUrl = newImageUrl;
    notifyListeners();
  }
}
