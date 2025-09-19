import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../services/delivery_service.dart';
import '../models/delivery_models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DeliveryService _deliveryService = DeliveryService();
  List<DeliveryJob> todayJobs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayJobs();
  }

  Future<void> _loadTodayJobs() async {
    try {
      setState(() => isLoading = true);
      final jobs = await _deliveryService.getTodayJobs();
      setState(() {
        todayJobs = jobs;
        isLoading = false;
      });
    } catch (error) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load today\'s jobs: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handlePickUp(DeliveryJob job) async {
    try {
      final result = await Navigator.pushNamed(
        context,
        '/delivery-details',
        arguments: job,
      );

      if (result == true) {
        _loadTodayJobs();
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatTimeSlot(String startTime, String endTime) {
    try {
      final start = _convertTo12Hour(startTime);
      final end = _convertTo12Hour(endTime);
      return '$start - $end';
    } catch (e) {
      return '$startTime - $endTime';
    }
  }

  String _convertTo12Hour(String time24) {
    final parts = time24.split(':');
    int hour = int.parse(parts[0]);
    final minute = parts[1].padLeft(2, '0');

    if (hour == 0) {
      return '12:$minute am';
    } else if (hour < 12) {
      return '$hour:$minute am';
    } else if (hour == 12) {
      return '12:$minute pm';
    } else {
      return '${hour - 12}:$minute pm';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom AppBar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/greenstem_logo.webp',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.local_shipping,
                            color: Color(0xFF2E7D32),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Greenstem Parts Delivery',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Today's Tasks",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${todayJobs.length} jobs',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Jobs list
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : todayJobs.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_shipping_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No deliveries scheduled for today',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _loadTodayJobs,
                              child: const Text('Refresh'),
                            ),
                          ],
                        ),
                      )
                          : RefreshIndicator(
                        onRefresh: _loadTodayJobs,
                        child: ListView.builder(
                          itemCount: todayJobs.length,
                          itemBuilder: (context, index) {
                            return JobCard(
                              job: todayJobs[index],
                              formatTimeSlot: _formatTimeSlot,
                              onPickUp: _handlePickUp,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const BottomNav(currentIndex: 0),
      ),
    );
  }
}

/// Extracted widget for cleaner code and performance
class JobCard extends StatelessWidget {
  final DeliveryJob job;
  final String Function(String, String) formatTimeSlot;
  final void Function(DeliveryJob) onPickUp;

  const JobCard({
    super.key,
    required this.job,
    required this.formatTimeSlot,
    required this.onPickUp,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    String statusText = job.status.toUpperCase();

    switch (job.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'PENDING';
        break;
      case 'picked_up':
        statusColor = Colors.blue;
        statusText = 'PICKED UP';
        break;
      case 'en_route':
        statusColor = Colors.purple;
        statusText = 'EN ROUTE';
        break;
      case 'delivered':
        statusColor = Colors.green;
        statusText = 'DELIVERED';
        break;
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time slot and status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green[800],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    formatTimeSlot(job.scheduledStartTime, job.scheduledEndTime),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Customer details
            Text(
              'Name: ${job.customerName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Contact: ${job.customerContact}'),
            const SizedBox(height: 4),
            Text('Order ID: ${job.id}'),
            const SizedBox(height: 8),
            Text(
              'Address: ${job.customerAddress}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),

            // Action button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: job.status == 'delivered'
                      ? Colors.green[100]
                      : Colors.grey[200],
                  foregroundColor: job.status == 'delivered'
                      ? Colors.green[700]
                      : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                onPressed:
                job.status == 'delivered' ? null : () => onPickUp(job),
                child: Text(
                  job.status == 'delivered' ? 'View Details' : 'Pick up',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
