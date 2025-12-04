import 'package:flutter/material.dart';

class OptimizerModal extends StatefulWidget {
  const OptimizerModal({super.key});

  @override
  State<OptimizerModal> createState() => _OptimizerModalState();
}

class _OptimizerModalState extends State<OptimizerModal> {
  bool running = false;

  void runOptimization() async {
    setState(() => running = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => running = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Optimize Trip'),
      content: running
          ? const CircularProgressIndicator()
          : const Text('Itinerary optimization'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: runOptimization, child: const Text('Run')),
      ],
    );
  }
}
