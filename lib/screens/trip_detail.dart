import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tropica_guide/screens/activities_tab.dart';
import 'package:tropica_guide/screens/checklist_tab.dart';
import 'package:tropica_guide/screens/overview_tab.dart';
import 'package:tropica_guide/screens/profile_screen.dart';

class TripDetail extends StatelessWidget {
  final String tripId;

  const TripDetail({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trips')
          .doc(tripId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final tripData = snapshot.data!.data() as Map<String, dynamic>;

        final startDate = (tripData['startDate'] as Timestamp).toDate();
        final endDate = (tripData['endDate'] as Timestamp).toDate();

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(tripData['title']),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Overview'),
                  Tab(text: 'Activities'),
                  Tab(text: 'Checklist'),
                ],
              ),
              actions: [
                IconButton(icon: const Icon(Icons.tune), onPressed: null),
                IconButton(
                  icon: const Icon(Icons.account_circle),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const ProfileScreen(),
                  ),
                ),
              ],
            ),
            body: TabBarView(
              children: [
                OverviewTab(tripId: tripId, tripData: tripData),
                ActivitiesTab(
                  tripId: tripId,
                  startDate: startDate,
                  endDate: endDate,
                ),
                ChecklistTab(tripId: tripId),
              ],
            ),
          ),
        );
      },
    );
  }
}
