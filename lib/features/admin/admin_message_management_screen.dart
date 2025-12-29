import 'package:flutter/material.dart';
import 'package:hire_me/services/admin_service.dart';
import 'package:hire_me/models/user_model.dart';

class AdminMessageManagementScreen extends StatefulWidget {
  const AdminMessageManagementScreen({super.key});

  @override
  State<AdminMessageManagementScreen> createState() => _AdminMessageManagementScreenState();
}

class _AdminMessageManagementScreenState extends State<AdminMessageManagementScreen> {
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await AdminService.getAllUsers();
      if (mounted) {
        setState(() {
          _users = users;
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

  Future<void> _createMessage() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CreateMessageDialog(users: _users),
    );

    if (result != null) {
      try {
        await AdminService.createMessageAsAdmin(
          senderUid: result['senderUid'] as String,
          receiverUid: result['receiverUid'] as String,
          content: result['content'] as String,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Message créé avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
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
        title: const Text('Gestion des Messages'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
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
                          'Créer un message entre utilisateurs',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _createMessage,
                        icon: const Icon(Icons.message),
                        label: const Text('Nouveau Message'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Instructions
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Instructions',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '• Sélectionnez un expéditeur et un destinataire',
                          style: TextStyle(fontSize: 14),
                        ),
                        const Text(
                          '• Rédigez le contenu du message',
                          style: TextStyle(fontSize: 14),
                        ),
                        const Text(
                          '• Un match sera automatiquement créé entre les utilisateurs',
                          style: TextStyle(fontSize: 14),
                        ),
                        const Text(
                          '• Le message apparaîtra dans leurs conversations',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Liste des utilisateurs
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Utilisateurs disponibles (${_users.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: _users.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.people_outline,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Aucun utilisateur trouvé',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _users.length,
                                  itemBuilder: (context, index) {
                                    final user = _users[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Theme.of(context).colorScheme.primary,
                                          child: Text(
                                            user.initials,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          user.fullName,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(user.email),
                                            if (user.jobTitle != null) Text(user.jobTitle!),
                                            if (user.companyName != null) Text(user.companyName!),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (user.isAdmin)
                                              const Icon(
                                                Icons.admin_panel_settings,
                                                color: Colors.orange,
                                                size: 20,
                                              ),
                                            if (user.isRecruiter)
                                              const Icon(
                                                Icons.business,
                                                color: Colors.blue,
                                                size: 20,
                                              ),
                                            if (user.isOnline)
                                              const Icon(
                                                Icons.circle,
                                                color: Colors.green,
                                                size: 12,
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class CreateMessageDialog extends StatefulWidget {
  final List<UserModel> users;

  const CreateMessageDialog({
    super.key,
    required this.users,
  });

  @override
  State<CreateMessageDialog> createState() => _CreateMessageDialogState();
}

class _CreateMessageDialogState extends State<CreateMessageDialog> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  UserModel? _selectedSender;
  UserModel? _selectedReceiver;
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _createMessage() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSender == null || _selectedReceiver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un expéditeur et un destinataire'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedSender!.uid == _selectedReceiver!.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('L\'expéditeur et le destinataire doivent être différents'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = {
        'senderUid': _selectedSender!.uid,
        'receiverUid': _selectedReceiver!.uid,
        'content': _contentController.text,
      };

      if (mounted) {
        Navigator.pop(context, result);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Créer un message'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sélection de l'expéditeur
              DropdownButtonFormField<UserModel>(
                value: _selectedSender,
                decoration: const InputDecoration(
                  labelText: 'Expéditeur',
                  border: OutlineInputBorder(),
                ),
                items: widget.users.map((user) {
                  return DropdownMenuItem(
                    value: user,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            user.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                user.email,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSender = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un expéditeur';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sélection du destinataire
              DropdownButtonFormField<UserModel>(
                value: _selectedReceiver,
                decoration: const InputDecoration(
                  labelText: 'Destinataire',
                  border: OutlineInputBorder(),
                ),
                items: widget.users
                    .where((user) => user.uid != _selectedSender?.uid)
                    .map((user) {
                  return DropdownMenuItem(
                    value: user,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          child: Text(
                            user.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                user.email,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedReceiver = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un destinataire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Contenu du message
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Contenu du message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le contenu du message est requis';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createMessage,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Créer'),
        ),
      ],
    );
  }
}
