import 'package:flutter/material.dart';
import 'package:tropica_guide/screens/profile_screen.dart';
import 'package:tropica_guide/screens/trip_detail.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

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
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
        child: Card(
          child: ListTile(
            title: Text('New Year\'s Getaway'),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('New York City, New York'),
                Text('Dec 31, 2025 - Jan 3, 2026'),
                SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.groups),
                    SizedBox(width: 10),
                    Text('Lauren, Taylor, Margo, Kim'),
                  ],
                ),
              ],
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TripDetail(tripId: '123')),
            ),
          ),
        ),
      ),
    );
  }
}
