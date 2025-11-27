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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Trip Detail'),
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
            OverviewTab(tripId: tripId),
            ActivitiesTab(tripId: tripId),
            ChecklistTab(tripId: tripId),
          ],
        ),
      ),
    );
  }
}
