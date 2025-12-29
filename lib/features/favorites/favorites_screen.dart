import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hire_me/design_system/widgets/adaptive_logo.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Veuillez vous connecter')),
      );
    }

    final jobFavs = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots();

    final candidateFavs = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('candidateFavorites')
        .orderBy('addedAt', descending: true)
        .snapshots();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Logo1(height: 28, fit: BoxFit.contain),
          bottom: const TabBar(tabs: [
            Tab(text: 'Offres'),
            Tab(text: 'Candidats'),
          ]),
        ),
        body: TabBarView(
          children: [
            _FavList(stream: jobFavs, emptyText: "Aucune offre en favori"),
            _FavList(stream: candidateFavs, emptyText: "Aucun candidat en favori"),
          ],
        ),
      ),
    );
  }
}

class _FavList extends StatelessWidget {
  const _FavList({required this.stream, required this.emptyText});
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(child: Text(emptyText));
        }
        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final d = docs[i].data();
            final title = (d['jobId'] ?? d['candidateUid'] ?? 'Favori') as String;
            return ListTile(
              title: Text(title),
              trailing: const Icon(Icons.chevron_right),
            );
          },
        );
      },
    );
  }
}


