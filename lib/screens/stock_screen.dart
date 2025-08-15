import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stockItems = [
      {'part': 'Brake Pad', 'qty': 20},
      {'part': 'Oil Filter', 'qty': 35},
      {'part': 'Air Filter', 'qty': 15},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: ListView.builder(
        itemCount: stockItems.length,
        itemBuilder: (context, index) {
          final item = stockItems[index];
          return Card(
            color: const Color(0xFFF1F8E9),
            child: ListTile(
              title: Text(
                item['part'].toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              subtitle: Text('Quantity: ${item['qty'].toString()}'),
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }
}
