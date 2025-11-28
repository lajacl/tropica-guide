import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewTripModal extends StatefulWidget {
  const NewTripModal({super.key});

  @override
  State<NewTripModal> createState() => _NewTripModalState();
}

class _NewTripModalState extends State<NewTripModal> {
  final titleCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  bool saving = false;

  Future<void> createTrip() async {
    if (titleCtrl.text.trim().isEmpty || startDate == null || endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All fields required')));
      return;
    }

    setState(() => saving = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('trips').add({
      'title': titleCtrl.text.trim(),
      'location': locationCtrl.text.trim().isEmpty
          ? null
          : locationCtrl.text.trim(),
      'ownerUid': uid,
      'participants': [uid],
      'startDate': startDate,
      'endDate': endDate,
      'settings': {'allowCollaborators': true, 'freezeItinerary': false},
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  Future<void> pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Trip'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleCtrl,
            decoration: const InputDecoration(labelText: 'Trip Title'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: locationCtrl,
            decoration: const InputDecoration(
              labelText: 'Location (optional)',
              hintText: 'e.g. Paris, France',
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            title: Text(
              startDate == null
                  ? 'Select start date'
                  : startDate!.toLocal().toString().split(' ')[0],
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => pickDate(true),
          ),
          ListTile(
            title: Text(
              endDate == null
                  ? 'Select end date'
                  : endDate!.toLocal().toString().split(' ')[0],
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => pickDate(false),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: saving ? null : createTrip,
          child: saving
              ? const CircularProgressIndicator()
              : const Text('Create'),
        ),
      ],
    );
  }
}
