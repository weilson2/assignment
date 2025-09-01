import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final records = [
      {'id': 'D001', 'date': '2025-08-01', 'status': 'Completed'},
      {'id': 'D002', 'date': '2025-08-02', 'status': 'Completed'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Records'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return Card(
            color: const Color(0xFFF1F8E9),
            child: ListTile(
              title: Text(
                'Delivery ID: ${record['id']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              subtitle: Text('Date: ${record['date']}'),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }
}
