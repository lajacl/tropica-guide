import 'package:flutter/material.dart';

class ActivitiesTab extends StatefulWidget {
  final String tripId;
  const ActivitiesTab({super.key, required this.tripId});

  @override
  State<ActivitiesTab> createState() => _ActivitiesTabState();
}

class _ActivitiesTabState extends State<ActivitiesTab> {
  final controller = TextEditingController();
  List<Map<String, String>> results = [];

  void search() {
    // Stubbed search
    setState(() {
      results = [
        {'name': 'Beach Walk', 'type': 'place'},
        {'name': 'Local Market', 'type': 'activity'},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Search places and activities',
          ),
        ),
        ElevatedButton(onPressed: search, child: const Text('Search')),
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (_, i) => ListTile(
              title: Text(results[i]['name']!),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
