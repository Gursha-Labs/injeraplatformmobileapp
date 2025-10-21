import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';

class VideoService {
  static final VideoService _instance = VideoService._internal();
  factory VideoService() => _instance;
  VideoService._internal();

  static const String baseUrl = 'https://api.pexels.com/videos';
  static const String apiKey =
      'Hm6chhCZB5j3uwQc6raftXAdCVkK3xbMqYAL7ek0BNKfPtu3pFvD4cuN'; // Get free key from pexels.com

  Future<List<Video>> getVideos() async {
    try {
      // For demo purposes, we'll use mock data since Pexels API requires authentication
      // In production, replace with your actual API
      await Future.delayed(
        const Duration(seconds: 5),
      ); // Simulate network delay

      return _getMockVideos();
    } catch (e) {
      throw Exception('Failed to load videos: $e');
    }
  }

  List<Video> _getMockVideos() {
    return [
      Video(
        id: '1',
        title: 'Amazing Ethiopian Landscape',
        description: 'Beautiful scenery from the highlands of Ethiopia',
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        thumbnail:
            'https://images.pexels.com/photos/247599/pexels-photo-247599.jpeg',
        user: User(
          id: '1',
          username: 'ethio_explorer',
          profileImage:
              'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg',
          followers: 15420,
        ),
        likes: 1245,
        comments: 89,
        shares: 45,
        music: 'Ethiopian Traditional Music - @ethio_beats',
      ),
      Video(
        id: '2',
        title: 'Injera Cooking Tutorial',
        description: 'Learn how to make traditional injera at home',
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        thumbnail:
            'https://images.pexels.com/photos/884437/pexels-photo-884437.jpeg',
        user: User(
          id: '2',
          username: 'ethio_chef',
          profileImage:
              'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg',
          followers: 89234,
        ),
        likes: 8923,
        comments: 234,
        shares: 567,
        music: 'Traditional Cooking Sounds - @kitchen_rhythms',
      ),
      Video(
        id: '3',
        title: 'Addis Ababa City Tour',
        description: 'Exploring the beautiful capital city',
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        thumbnail:
            'https://images.pexels.com/photos/1058759/pexels-photo-1058759.jpeg',
        user: User(
          id: '3',
          username: 'city_wanderer',
          profileImage:
              'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg',
          followers: 34215,
        ),
        likes: 4567,
        comments: 123,
        shares: 89,
        music: 'Urban Ethiopian Beats - @addis_vibes',
      ),
    ];
  }
}
