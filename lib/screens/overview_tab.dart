import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tropica_guide/modals/add_companion_modal.dart';

class OverviewTab extends StatelessWidget {
  final String tripId;
  final Map<String, dynamic> tripData;

  const OverviewTab({super.key, required this.tripId, required this.tripData});

  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  void showAddCompanionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddCompanionModal(tripId: tripId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(20),
      child: Column(
        spacing: 20,
        children: [
          Card(
            child: ListTile(
              title: Text(tripData['title']),
              subtitle: Text(
                '${tripData['location'] ?? ''}\n${formatDate((tripData['startDate'] as Timestamp).toDate())} - ${formatDate((tripData['endDate'] as Timestamp).toDate())}',
              ),
            ),
          ),
          const Divider(),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('trips')
                .doc(tripId)
                .snapshots(),
            builder: (context, tripSnapshot) {
              if (!tripSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final trip = tripSnapshot.data!;
              final participantUids = List<String>.from(
                trip['participants'] ?? [],
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TravelersSection(uids: participantUids),
                  TextButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Companion'),
                    onPressed: () => showAddCompanionModal(context),
                  ),
                ],
              );
            },
          ),
          const Divider(),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('trips/${tripId}/itinerary_items')
                .orderBy('dayIndex')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final items = snapshot.data!.docs;
              return Expanded(
                child: ReorderableListView(
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    final moved = items[oldIndex];
                    FirebaseFirestore.instance
                        .collection('trips/${tripId}/itinerary_items')
                        .doc(moved.id)
                        .update({'dayIndex': newIndex});
                  },
                  children: [
                    for (int i = 0; i < items.length; i++)
                      ListTile(
                        key: ValueKey(items[i].id),
                        title: Text(items[i]['name']),
                        // subtitle: Text(items[i]['type']),
                        trailing: const Icon(Icons.drag_handle),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TravelersSection extends StatelessWidget {
  final List<String> uids;

  const _TravelersSection({required this.uids});

  @override
  Widget build(BuildContext context) {
    if (uids.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No travelers added'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Travelers', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: uids.map((uid) {
            return _TravelerChip(uid: uid);
          }).toList(),
        ),
      ],
    );
  }
}

class _TravelerChip extends StatelessWidget {
  final String uid;

  const _TravelerChip({required this.uid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Chip(label: Text('Loading...'));
        }

        final user = snapshot.data!;
        final name = '${user['firstName']} ${user['lastName']}';
        final email = user['email'];

        return Tooltip(
          message: email,
          child: Chip(
            avatar: const Icon(Icons.person, size: 18),
            label: Text(name),
          ),
        );
      },
    );
  }
}
