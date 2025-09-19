import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/bottom_nav.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = _fetchRecords();
  }

  Future<List<Map<String, dynamic>>> _fetchRecords() async {
    final response = await supabase
        .from('delivery_jobs') // replace with your actual table name
        .select()
        .order('created_at', ascending: false);

    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Records'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _recordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return const Center(
              child: Text('No delivery records found'),
            );
          }

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final status = (record['status'] ?? '').toString().toLowerCase();

              bool isDelivered = status == 'delivered';

              return Card(
                color: const Color(0xFFF1F8E9),
                margin:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    'Delivery ID: ${record['id']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer: ${record['customer_name']}'),
                      Text('Contact: ${record['customer_contact']}'),
                      Text('Address: ${record['customer_address']}'),
                      Text('Scheduled: ${record['scheduled_date']} '
                          '${record['scheduled_start_time']} - ${record['scheduled_end_time']}'),
                      if (isDelivered && record['delivered_at'] != null)
                        Text('Delivered At: ${record['delivered_at']}'),
                    ],
                  ),
                  trailing: Icon(
                    isDelivered
                        ? Icons.check_circle
                        : Icons.pending_actions,
                    color:
                    isDelivered ? Colors.green : Colors.orange,
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }
}
