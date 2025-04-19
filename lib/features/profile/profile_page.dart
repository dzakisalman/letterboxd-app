import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letterboxd/core/models/user.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual user data from auth service
    final user = User(
      id: '1',
      username: 'John Doe',
      email: 'john@example.com',
      watchedMovies: 42,
      reviews: 10,
      followers: 100,
      following: 50,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF14181C),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[800],
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Watched', user.watchedMovies),
                _buildStatColumn('Reviews', user.reviews),
                _buildStatColumn('Followers', user.followers),
                _buildStatColumn('Following', user.following),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Activity'),
            const SizedBox(height: 16),
            _buildActivityList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildActivityList() {
    // TODO: Replace with actual activity data
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Container(
            width: 50,
            height: 75,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          title: const Text(
            'Movie Title',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            'Rated 4.5 stars',
            style: TextStyle(color: Colors.grey[400]),
          ),
          trailing: Text(
            '2h ago',
            style: TextStyle(color: Colors.grey[400]),
          ),
        );
      },
    );
  }
} 