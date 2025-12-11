import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tropica_guide/modals/new_trip_modal.dart';
import 'package:tropica_guide/screens/profile_screen.dart';
import 'package:tropica_guide/screens/trip_detail.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  // Date format helper
  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const ProfileScreen(),
            ),
          ),
        ],
      ),
      // Button to add a new trip
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (_) => const NewTripModal());
        },
        child: const Icon(Icons.add),
      ),
      // Retrieve trips from database
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('trips').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final d = doc.data();
              return Card(
                margin: EdgeInsetsGeometry.all(20),
                child: ListTile(
                  title: Text(d['title']),
                  subtitle: Text(
                    '${d['location'] ?? ''}\n${formatDate((d['startDate'] as Timestamp).toDate())} - ${formatDate((d['endDate'] as Timestamp).toDate())}',
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TripDetail(tripId: doc.id),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
