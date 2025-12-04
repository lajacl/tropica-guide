import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddCompanionModal extends StatefulWidget {
  final String tripId;

  const AddCompanionModal({super.key, required this.tripId});

  @override
  State<AddCompanionModal> createState() => _AddCompanionModalState();
}

class _AddCompanionModalState extends State<AddCompanionModal> {
  final _emailController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return Padding(
      padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Companion', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),

          /// EXISTING COMPANIONS
          Text('From your companions'),
          const SizedBox(height: 8),
          _ExistingCompanionsList(
            onSelect: (uid) => _addUserToTripAndCompanions(uid, context),
          ),

          const Divider(),

          /// ADD BY EMAIL
          Text('Add by email'),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email address'),
          ),

          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loading ? null : () => _addByEmail(context),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addUserToTripAndCompanions(
    String targetUid,
    BuildContext context,
  ) async {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final tripRef = FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId);
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid);

    if (targetUid == currentUid) {
      _showError(context, 'You cannot add yourself');
      return;
    }

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final tripSnap = await tx.get(tripRef);
      final userSnap = await tx.get(userRef);

      final participants = List<String>.from(tripSnap['participants'] ?? []);
      final companions = List<String>.from(userSnap['companions'] ?? []);

      if (!participants.contains(targetUid)) {
        participants.add(targetUid);
        tx.update(tripRef, {'participants': participants});
      }

      if (!companions.contains(targetUid)) {
        companions.add(targetUid);
        tx.update(userRef, {'companions': companions});
      }
    });

    Navigator.pop(context);
  }

  Future<void> _addByEmail(BuildContext context) async {
    final email = _emailController.text.trim().toLowerCase();
    if (email.isEmpty) return;

    setState(() => _loading = true);

    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      _showError(context, 'User not found');
      setState(() => _loading = false);
      return;
    }

    final targetUid = query.docs.first.id;
    await _addUserToTripAndCompanions(targetUid, context);

    setState(() => _loading = false);
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _ExistingCompanionsList extends StatelessWidget {
  final Function(String uid) onSelect;

  const _ExistingCompanionsList({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final companions = List<String>.from(
          snapshot.data!['companions'] ?? [],
        );

        if (companions.isEmpty) {
          return const Text('No companions yet');
        }

        return Wrap(
          spacing: 8,
          children: companions.map((cUid) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(cUid)
                  .get(),
              builder: (context, snap) {
                if (!snap.hasData) return const SizedBox();

                final u = snap.data!;
                final name = '${u['firstName']} ${u['lastName']}';

                return ActionChip(
                  label: Text(name),
                  onPressed: () => onSelect(cUid),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
