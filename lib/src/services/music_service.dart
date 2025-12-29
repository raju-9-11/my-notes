
import 'package:flutter_riverpod/flutter_riverpod.dart';

final musicServiceProvider = Provider((ref) => MusicService());

class MusicService {
  // Mock search results
  Future<List<Map<String, String>>> searchMusic(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {'id': '1', 'title': 'Lofi Beats', 'type': 'Spotify', 'uri': 'spotify:playlist:37i9dQZF1DWWQRwui0ExPn'},
      {'id': '2', 'title': 'Morning Energy', 'type': 'Spotify', 'uri': 'spotify:playlist:37i9dQZF1DXcBWIGoYBM5M'},
      {'id': '3', 'title': 'Nature Sounds', 'type': 'YouTube', 'uri': 'https://www.youtube.com/watch?v=eKFTSSKCzWA'},
      {'id': '4', 'title': 'Motivation', 'type': 'YouTube', 'uri': 'https://www.youtube.com/watch?v=5qap5aO4i9A'},
    ];
  }
}
