import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class DeliveryScreen extends StatelessWidget {
  const DeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deliveries = [
      {'id': 'D001', 'time': '09:00 AM', 'priority': 'High', 'status': 'Pending'},
      {'id': 'D002', 'time': '11:00 AM', 'priority': 'Medium', 'status': 'Pending'},
      {'id': 'D003', 'time': '02:00 PM', 'priority': 'Low', 'status': 'Completed'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Schedule'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: ListView.builder(
        itemCount: deliveries.length,
        itemBuilder: (context, index) {
          final delivery = deliveries[index];
          return Card(
            color: const Color(0xFFF1F8E9),
            child: ListTile(
              title: Text(
                'Delivery ID: ${delivery['id']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              subtitle: Text(
                'Time: ${delivery['time']} | Priority: ${delivery['priority']}',
                style: const TextStyle(color: Colors.black87),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: delivery['status'] == 'Completed'
                      ? Colors.green.shade200
                      : Colors.orange.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  delivery['status']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/delivery-details', arguments: delivery);
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }
}
