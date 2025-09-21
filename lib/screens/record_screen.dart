import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/bottom_nav.dart';
import '../models/delivery_models.dart';
import 'delivery_details_screen.dart';

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
        .eq('assigned_personnel_id', userId)
        .order('created_at', ascending: false);

    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Format date and time to readable format
  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'Not available';

    try {
      final dateTime = DateTime.parse(dateTimeString);

      // Format date part
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];

      final day = dateTime.day;
      final month = months[dateTime.month - 1];
      final year = dateTime.year;

      // Format time part with AM/PM
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      return '$day $month $year, $displayHour:$minute $period';
    } catch (e) {
      return 'Invalid date';
    }
  }

  // Format just the date part
  String _formatDate(String? dateString) {
    if (dateString == null) return 'Not available';

    try {
      final date = DateTime.parse(dateString);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];

      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  // Format time range for scheduled times
  String _formatTimeRange(String? startTime, String? endTime) {
    if (startTime == null || endTime == null) return 'Not scheduled';

    try {
      // These might be just time strings like "14:30:00" or full datetime
      String formatTime(String timeStr) {
        DateTime time;
        if (timeStr.contains('T')) {
          // Full datetime string
          time = DateTime.parse(timeStr);
        } else {
          // Just time string, create a dummy date
          time = DateTime.parse('2000-01-01T$timeStr');
        }

        final hour = time.hour;
        final minute = time.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

        return '$displayHour:$minute $period';
      }

      return '${formatTime(startTime)} - ${formatTime(endTime)}';
    } catch (e) {
      return '$startTime - $endTime'; // Fallback to original if parsing fails
    }
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

        // Convert JSON record into DeliveryJob model
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
                Text('Scheduled: ${_formatDate(record['scheduled_date'])} '
                    '${_formatTimeRange(record['scheduled_start_time'], record['scheduled_end_time'])}'),
                if (status == 'delivered' && record['delivered_at'] != null)
                  Text('Delivered At: ${_formatDateTime(record['delivered_at'])}'),
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
                      // Navigate to DeliveryDetailsScreen with job
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
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF2E7D32),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
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