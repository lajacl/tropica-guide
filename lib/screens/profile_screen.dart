import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tropica_guide/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  bool loading = true;
  bool saving = false;

  User get user => FirebaseAuth.instance.currentUser!;
  DocumentReference get userRef =>
      FirebaseFirestore.instance.collection('users').doc(user.uid);

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final doc = await userRef.get();
    final data = doc.data() as Map<String, dynamic>;

    firstNameCtrl.text = data['firstName'] ?? '';
    lastNameCtrl.text = data['lastName'] ?? '';

    setState(() => loading = false);
  }

  Future<void> saveProfile() async {
    setState(() => saving = true);
    await userRef.update({
      'firstName': firstNameCtrl.text.trim(),
      'lastName': lastNameCtrl.text.trim(),
    });
    setState(() => saving = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  Future<void> addCompanion() async {
    final emailCtrl = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Companion'),
        content: TextField(
          controller: emailCtrl,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, emailCtrl.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: result)
        .get();

    if (query.docs.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not found')));
      return;
    }

    final companionDoc = query.docs.first;

    // 🚫 Prevent adding self
    if (companionDoc.id == user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot add yourself as a companion')),
      );
      return;
    }

    await userRef.update({
      'companions': FieldValue.arrayUnion([query.docs.first.id]),
    });
  }

  Future<void> removeCompanion(String uid) async {
    await userRef.update({
      'companions': FieldValue.arrayRemove([uid]),
    });
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {
              logout();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextFormField(
              controller: firstNameCtrl,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextFormField(
              controller: lastNameCtrl,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            TextFormField(
              initialValue: user.email,
              decoration: const InputDecoration(labelText: 'Email'),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: saving ? null : saveProfile,
              child: saving
                  ? const CircularProgressIndicator()
                  : const Text('Save Profile'),
            ),
            const Divider(height: 32),
            const Text(
              'Travel Companions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StreamBuilder<DocumentSnapshot>(
              stream: userRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final companions = List<String>.from(data['companions'] ?? []);

                if (companions.isEmpty) {
                  return const Text('No companions added');
                }

                return Column(
                  children: companions.map((companionUid) {
                    return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(companionUid)
                          .snapshots(),
                      builder: (context, userSnap) {
                        if (!userSnap.hasData) {
                          return const ListTile(title: Text('Loading...'));
                        }

                        final userData =
                            userSnap.data!.data() as Map<String, dynamic>?;

                        final name = userData == null
                            ? 'Unknown User'
                            : '${userData['firstName']} ${userData['lastName']}';

                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(name),
                          subtitle: Text(userData?['email'] ?? ''),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle),
                            onPressed: () => removeCompanion(companionUid),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('Add Companion'),
              onPressed: addCompanion,
            ),
          ],
        ),
      ),
    );
  }
}
