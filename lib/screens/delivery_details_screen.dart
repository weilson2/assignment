import 'package:flutter/material.dart';
import '../models/delivery_models.dart';
import '../services/delivery_service.dart';

class DeliveryDetailsScreen extends StatefulWidget {
  const DeliveryDetailsScreen({super.key});

  @override
  State<DeliveryDetailsScreen> createState() => _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends State<DeliveryDetailsScreen> {
  final DeliveryService _deliveryService = DeliveryService();

  DeliveryJob? job;
  bool isLoading = false;
  bool proofUploaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (job == null) {
      job = ModalRoute.of(context)!.settings.arguments as DeliveryJob;
    }
  }

  Future<void> _updateJobStatus(String newStatus) async {
    if (job == null) return;

    setState(() => isLoading = true);

    try {
      bool success = await _deliveryService.updateJobStatus(job!.id, newStatus);

      if (success && mounted) {
        setState(() {
          job = job!.copyWith(status: newStatus);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${newStatus.replaceAll('_', ' ').toUpperCase()}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleEnRoute() async {
    await _updateJobStatus('en_route');
  }

  Future<void> _handleMarkAsDone() async {
    // Simulate image upload
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload Proof of Delivery'),
          content: const Text('Simulating image upload for proof of delivery.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _simulateImageUpload();
              },
              child: const Text('Upload Proof'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _simulateImageUpload() async {
    if (job == null) return;

    setState(() => isLoading = true);

    try {
      String? imageUrl = await _deliveryService.simulateUploadProofImage(job!.id);

      if (imageUrl != null && mounted) {
        setState(() {
          job = job!.copyWith(
            status: 'delivered',
            proofImageUrl: imageUrl,
            deliveredAt: DateTime.now(),
          );
          proofUploaded = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload proof: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _viewProofImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Delivery Proof',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Proof image uploaded successfully'),
                        Text('(Simulated for assignment)',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _notifyCustomer() async {
    setState(() => isLoading = true);

    try {
      bool success = await _deliveryService.notifyCustomer(job!.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer ${job!.customerName} has been notified!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to notify customer'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildCustomerInfo() {
    if (job == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: Color(0xFF2E7D32)),
              const SizedBox(width: 8),
              Text(
                job!.customerName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone, 'Contact', job!.customerContact),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.receipt, 'Order ID', job!.id),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.access_time, 'Time', _formatTimeSlot()),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.circle, 'Status', job!.status.toUpperCase(),
              color: _getStatusColor()),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Address',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job!.customerAddress,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: color ?? Colors.black87,
            fontWeight: color != null ? FontWeight.bold : null,
          ),
        ),
      ],
    );
  }

  Widget _buildProductsList() {
    if (job?.items.isEmpty ?? true) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Items to Deliver',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...job!.items.map((item) => _buildProductItem(item)),
        ],
      ),
    );
  }

  Widget _buildProductItem(DeliveryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Product image placeholder
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.inventory_2, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product?.name ?? 'Product ${item.productId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${item.productId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantity: ${item.quantity}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Navigate to product details if available
            },
            child: const Text('view details >'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (job == null) return const SizedBox.shrink();

    String buttonText;
    VoidCallback? onPressed;
    Color backgroundColor = const Color(0xFF2E7D32);

    if (job!.status == 'delivered' && job!.proofImageUrl != null) {
      // Show both buttons for delivered status
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _viewProofImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('View Proof'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : _notifyCustomer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Notify Customer'),
            ),
          ),
        ],
      );
    }

    switch (job!.status) {
      case 'pending':
      case 'picked_up':
        buttonText = 'En Route';
        onPressed = _handleEnRoute;
        break;
      case 'en_route':
        buttonText = 'Mark as Done';
        onPressed = _handleMarkAsDone;
        break;
      default:
        buttonText = 'Delivered';
        onPressed = null;
        backgroundColor = Colors.grey;
    }

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(buttonText),
      ),
    );
  }

  String _formatTimeSlot() {
    if (job == null) return '';
    return '${job!.scheduledStartTime} - ${job!.scheduledEndTime}';
  }

  Color _getStatusColor() {
    switch (job?.status) {
      case 'pending':
        return Colors.orange;
      case 'picked_up':
        return Colors.blue;
      case 'en_route':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (job == null) {
      return const Scaffold(
        body: Center(child: Text('No delivery job data found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Detail'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCustomerInfo(),
            _buildProductsList(),
            const SizedBox(height: 24),
            _buildActionButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}