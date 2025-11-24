import 'package:flutter/material.dart';

class ChecklistTab extends StatefulWidget {
  final String tripId;
  const ChecklistTab({super.key, required this.tripId});

  @override
  State<ChecklistTab> createState() => _ChecklistTabState();
}

class _ChecklistTabState extends State<ChecklistTab> {
  Map<String, bool> checklist = {
    'Umbrella': true,
    'Hand warmers': false,
    'Cork screw': true,
  }; // Stubbed

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: checklist.entries.map((entry) {
        return CheckboxListTile(
          title: Text(entry.key),
          value: entry.value,
          onChanged: (bool? newValue) {
            setState(() {
              checklist[entry.key] = newValue!;
            });
          },
        );
      }).toList(),
    );
  }
}
