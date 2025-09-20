import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/bottom_nav.dart';
import '../models/delivery_models.dart';
import 'delivery_details_screen.dart'; // ✅ make sure this import path matches your project

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _recordsFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _recordsFuture = _fetchRecords();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<List<Map<String, dynamic>>> _fetchRecords() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      debugPrint("⚠️ No user logged in");
      return [];
    }

    final response = await supabase
        .from('delivery_jobs')
        .select('''
          *,
          delivery_items(
            *,
            products(
              id,
              name,
              price,
              image_url
            )
          )
        ''')
        .eq('assigned_personnel_id', userId) // ✅ only for current user
        .order('created_at', ascending: false);

    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Widget _buildRecordList(List<Map<String, dynamic>> records) {
    if (records.isEmpty) {
      return const Center(child: Text("No records found"));
    }

    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        final status = (record['status'] ?? '').toString().toLowerCase();

        // ✅ Convert JSON record into DeliveryJob model
        final job = DeliveryJob.fromJson(record);

        return Card(
          color: const Color(0xFFF1F8E9),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                if (status == 'delivered' && record['delivered_at'] != null)
                  Text('Delivered At: ${record['delivered_at']}'),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      // ✅ Navigate to DeliveryDetailsScreen with job
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DeliveryDetailsScreen(),
                          settings: RouteSettings(arguments: job),
                        ),
                      );
                    },
                    child: const Text("View Record"),
                  ),
                ),
              ],
            ),
            trailing: Icon(
              status == 'delivered'
                  ? Icons.check_circle
                  : status == 'en_route'
                  ? Icons.local_shipping
                  : Icons.pending_actions,
              color: status == 'delivered'
                  ? Colors.green
                  : status == 'en_route'
                  ? Colors.blue
                  : Colors.orange,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Delivery Records'),
          backgroundColor: const Color(0xFF2E7D32),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,          // ✅ active tab text
            unselectedLabelColor: Colors.white70, // ✅ inactive tab text
            tabs: const [
              Tab(text: "Picked Up"),
              Tab(text: "En Route"),
              Tab(text: "Delivered"),
            ],
          ),
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
          final pickedUp = records
              .where((r) =>
          (r['status'] ?? '').toString().toLowerCase() == 'picked_up')
              .toList();
          final enRoute = records
              .where((r) =>
          (r['status'] ?? '').toString().toLowerCase() == 'en_route')
              .toList();
          final delivered = records
              .where((r) =>
          (r['status'] ?? '').toString().toLowerCase() == 'delivered')
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildRecordList(pickedUp),
              _buildRecordList(enRoute),
              _buildRecordList(delivered),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }
}
