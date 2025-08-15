import 'package:flutter/material.dart';

class DeliveryDetailsScreen extends StatelessWidget {
  const DeliveryDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final delivery = ModalRoute.of(context)!.settings.arguments as Map?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Details'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: delivery == null
          ? const Center(child: Text('No delivery selected.'))
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery ID: ${delivery['id']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 10),
            Text('Time: ${delivery['time']}'),
            Text('Priority: ${delivery['priority']}'),
            Text('Status: ${delivery['status']}'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Add delivery status update logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Marked as Delivered!')),
                );
              },
              child: const Text('Mark as Delivered'),
            ),
          ],
        ),
      ),
    );
  }
}
