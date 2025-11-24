import 'package:flutter/material.dart';

class OverviewTab extends StatelessWidget {
  final String tripId;
  const OverviewTab({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.directional(start: 20, end: 20, top: 20),
      child: Column(
        children: [
          Card(
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
            ),
          ),
          SizedBox(height: 20),
          ListTile(
            title: Text('Statue of Liberty'),
            subtitle: Text('place'),
            trailing: const Icon(Icons.drag_handle),
          ),
        ],
      ),
    );
  }
}
