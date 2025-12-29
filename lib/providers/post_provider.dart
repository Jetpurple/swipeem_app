import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hire_me/models/post_model.dart';
import 'package:hire_me/services/post_service.dart';

final postsProvider = Provider<List<PostModel>>((ref) {
  // No demo mode. Implement real fetch here if needed.
  return const [];
});

final recentPostsStreamProvider = StreamProvider<List<PostModel>>((ref) {
  return PostService.streamRecentPosts();
});


