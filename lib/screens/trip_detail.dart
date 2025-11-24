import 'package:flutter/material.dart';

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
          actions: [IconButton(icon: const Icon(Icons.tune), onPressed: null)],
        ),
        body: TabBarView(
          children: [Text('Overview'), Text('Activities'), Text('Checklist')],
        ),
      ),
    );
  }
}
