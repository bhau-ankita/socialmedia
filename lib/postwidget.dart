import 'package:flutter/material.dart';

class PostWidget extends StatelessWidget {
  final dynamic post;

  PostWidget({required this.post});

  @override
  Widget build(BuildContext context) {
    final String description = post['description'] ?? '';
    final String imageUrl = post['image_url'] ?? '';
    final List<dynamic> taggedUsers = post['tagged_users'] ?? [];

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                )
              : Placeholder(
                  fallbackHeight: 200,
                  color: Colors.grey,
                ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 8.0),
                if (taggedUsers.isNotEmpty)
                  Text(
                    'Tagged Users: ${taggedUsers.join(', ')}',
                    style: TextStyle(color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
