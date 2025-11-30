import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ActivitiesTab extends StatefulWidget {
  final String tripId;
  final DateTime startDate;
  final DateTime endDate;

  const ActivitiesTab({
    super.key,
    required this.tripId,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<ActivitiesTab> createState() => _ActivitiesTabState();
}

class _ActivitiesTabState extends State<ActivitiesTab> {
  final searchCtrl = TextEditingController();
  String query = '';

  List<DateTime> getTripDays(DateTime start, DateTime end) {
    final days = <DateTime>[];
    DateTime current = start;

    while (!current.isAfter(end)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final days = getTripDays(widget.startDate, widget.endDate);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: searchCtrl,
            decoration: const InputDecoration(
              labelText: 'Search activities',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => query = v.toLowerCase()),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('activities')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final results = snapshot.data!.docs.where((doc) {
                  final name = doc['name'].toString().toLowerCase();
                  return name.contains(query);
                }).toList();

                if (results.isEmpty) {
                  return const Center(child: Text('No activities found'));
                }

                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final activity = results[index];
                    return Card(
                      child: ListTile(
                        title: Text(activity['name']),
                        subtitle: Text(
                          '${activity['estimatedMinutes']} minutes',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            showAddToDayDialog(
                              context,
                              activity,
                              days,
                              dateFormat,
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void showAddToDayDialog(
    BuildContext context,
    QueryDocumentSnapshot activity,
    List<DateTime> days,
    DateFormat dateFormat,
  ) {
    int selectedDayIndex = 0;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add to Day'),
        content: DropdownButtonFormField<int>(
          value: selectedDayIndex,
          items: List.generate(days.length, (i) {
            return DropdownMenuItem(
              value: i,
              child: Text('Day ${i + 1} — ${dateFormat.format(days[i])}'),
            );
          }),
          onChanged: (v) => selectedDayIndex = v!,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('trips')
                  .doc(widget.tripId)
                  .collection('itinerary_items')
                  .add({
                    'type': 'activity',
                    'name': activity['name'],
                    'estimatedMinutes': activity['estimatedMinutes'],
                    'dayIndex': selectedDayIndex,
                    'addedBy': FirebaseAuth.instance.currentUser!.uid,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to itinerary')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
