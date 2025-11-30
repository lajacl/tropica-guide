import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OverviewTab extends StatelessWidget {
  final String tripId;
  final Map<String, dynamic> tripData;

  const OverviewTab({super.key, required this.tripId, required this.tripData});

  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: EdgeInsetsGeometry.all(20),
          child: ListTile(
            title: Text(tripData['title']),
            subtitle: Text(
              '${tripData['location'] ?? ''}\n${formatDate((tripData['startDate'] as Timestamp).toDate())} - ${formatDate((tripData['endDate'] as Timestamp).toDate())}',
            ),
          ),
        ),
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
    );
  }
}
