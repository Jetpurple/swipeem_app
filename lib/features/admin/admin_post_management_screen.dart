import 'package:flutter/material.dart';
import 'package:hire_me/services/admin_service.dart';
import 'package:hire_me/models/post_model.dart';
import 'package:hire_me/widgets/create_post_form.dart';

class AdminPostManagementScreen extends StatefulWidget {
  const AdminPostManagementScreen({super.key});

  @override
  State<AdminPostManagementScreen> createState() => _AdminPostManagementScreenState();
}

class _AdminPostManagementScreenState extends State<AdminPostManagementScreen> {
  List<PostModel> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final posts = await AdminService.getAllPosts();
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createPost() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const CreatePostDialog(),
    );

    if (result != null) {
      try {
        await AdminService.createPostAsAdmin(
          title: result['title'] as String,
          content: result['content'] as String,
          softSkills: result['softSkills'] as List<String>? ?? [],
          hardSkills: result['hardSkills'] as List<String>? ?? [],
          domain: result['domain'] as String?,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Offre publiée avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
          _loadPosts();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deletePost(PostModel post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le post'),
        content: Text('Êtes-vous sûr de vouloir supprimer le post "${post.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AdminService.deletePost(post.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post supprimé avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
          _loadPosts();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Posts'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPosts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // En-tête avec bouton d'ajout
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Posts (${_posts.length})',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _createPost,
                        icon: const Icon(Icons.add),
                        label: const Text('Nouveau Post'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Liste des posts
                Expanded(
                  child: _posts.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.article_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Aucun post trouvé',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _posts.length,
                          itemBuilder: (context, index) {
                            final post = _posts[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(
                                  post.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      post.content,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    if (post.tags.isNotEmpty)
                                      Wrap(
                                        spacing: 4,
                                        children: post.tags
                                            .take(3)
                                            .map((tag) => Chip(
                                                  label: Text(tag),
                                                  backgroundColor: Theme.of(context)
                                                      .colorScheme
                                                      .primaryContainer,
                                                  labelStyle: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryContainer,
                                                    fontSize: 12,
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Créé le ${_formatDate(post.createdAt)}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Supprimer'),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'delete') {
                                      _deletePost(post);
                                    }
                                  },
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class CreatePostDialog extends StatefulWidget {
  const CreatePostDialog({super.key});

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  bool _isLoading = false;

  void _handleSubmit(Map<String, dynamic> data) {
    Navigator.pop(context, data);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Publier une nouvelle offre'),
      content: SizedBox(
        width: double.maxFinite,
        height: 600,
        child: CreatePostForm(
          onSubmit: _handleSubmit,
          isLoading: _isLoading,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}
