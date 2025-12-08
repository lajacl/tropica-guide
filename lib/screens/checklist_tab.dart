import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChecklistTab extends StatefulWidget {
  final String tripId;
  const ChecklistTab({super.key, required this.tripId});

  @override
  State<ChecklistTab> createState() => _ChecklistTabState();
}

class _ChecklistTabState extends State<ChecklistTab> {
  final itemCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: itemCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Item name',
                    prefixIcon: Icon(Icons.luggage),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('trips/${widget.tripId}/checklist')
                      .add({'item': itemCtrl.text.trim(), 'checked': false});
                  itemCtrl.text = '';
                },
                label: Text('Add'),
                icon: Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('trips/${widget.tripId}/checklist')
                  .snapshots(),
              builder: (_, snap) {
                if (!snap.hasData) return const CircularProgressIndicator();
                return ListView(
                  children: snap.data!.docs.map((d) {
                    return CheckboxListTile(
                      title: Text(d['item']),
                      value: d['checked'],
                      onChanged: (b) async {
                        await FirebaseFirestore.instance
                            .collection('trips/${widget.tripId}/checklist')
                            .doc(d.id)
                            .update({'checked': b});
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
