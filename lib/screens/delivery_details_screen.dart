import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is DeliveryJob) {
        job = args;
        // debug: what was passed
        debugPrint('DeliveryDetailsScreen: received job id=${job!.id}, items=${job!.items.length}');
        // Always try to fetch the full job details (items + products)
        _fetchJobDetails(job!.id);
      } else {
        debugPrint('DeliveryDetailsScreen: no DeliveryJob passed (args=$args)');
      }
    }
  }

  Future<void> _fetchJobDetails(String jobId) async {
    setState(() => isLoading = true);
    try {
      // optional: print inside service if you want raw supabase response
      final fullJob = await _deliveryService.getJobById(jobId);
      debugPrint('DeliveryDetailsScreen: fetched job fullJob?.items.length=${fullJob?.items.length}');
      if (!mounted) return;
      setState(() {
        if (fullJob != null) job = fullJob;
      });
    } catch (e, st) {
      debugPrint('DeliveryDetailsScreen: failed to fetch job: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load job details: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
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
        debugPrint('Status updated to $newStatus');
      }
    } catch (error) {
      debugPrint('Failed to update status: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
  Future<void> _assignJobToCurrentUser() async {
    if (job == null) return;
    setState(() => isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in")),
        );
        return;
      }

      final success =
      await _deliveryService.assignJobToCurrentUser(job!.id, userId);

      if (success && mounted) {
        setState(() {
          job = job!.copyWith(
            status: "picked_up",
            assignedPersonnelId: userId,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Job successfully assigned to you!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('assignJobToCurrentUser error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to assign job: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _simulateImageUpload() async {
    if (job == null) return;
    setState(() => isLoading = true);

    try {
      String? imageUrl = await _deliveryService.simulateUploadProofImage(job!.id);
      if (imageUrl != null && mounted) {
        setState(() {
          job = job!.copyWith(status: 'delivered', proofImageUrl: imageUrl, deliveredAt: DateTime.now());
          proofUploaded = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delivery completed successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (error) {
      debugPrint('simulateUploadProofImage error: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload proof: $error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _viewProofImage() async {
    if (job?.proofImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No proof image available')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Delivery Proof', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              // show image if real url, otherwise placeholder
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[200]),
                child: job!.proofImageUrl != null
                    ? Image.network(job!.proofImageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
                  return const Center(child: Icon(Icons.broken_image, size: 48));
                })
                    : const Center(child: Icon(Icons.image, size: 48)),
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
            ]),
          ),
        );
      },
    );
  }

  Future<void> _notifyCustomer() async {
    if (job == null) return;
    setState(() => isLoading = true);
    try {
      bool success = await _deliveryService.notifyCustomer(job!.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Customer ${job!.customerName} has been notified!')));
      }
    } catch (e) {
      debugPrint('notifyCustomer error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to notify customer')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ========== UI helpers ==========

  Widget _buildCustomerInfo() {
    if (job == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.person, color: Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          Expanded(child: Text(job!.customerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 8),
        Text('Contact: ${job!.customerContact}'),
        const SizedBox(height: 4),
        Text('Order ID: ${job!.id}'),
        const SizedBox(height: 4),
        Text('Estimated: ${job!.scheduledEndTime}'),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.circle, size: 14),
          const SizedBox(width: 6),
          Text('Status: ', style: const TextStyle(color: Colors.grey)),
          Text(job!.status.toUpperCase(), style: TextStyle(color: _getStatusColor(), fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.location_on, color: Colors.blue, size: 16),
          const SizedBox(width: 6),
          Expanded(child: Text(job!.customerAddress, style: const TextStyle(color: Colors.black87))),
        ]),
      ]),
    );
  }

  Widget _buildProductsList() {
    if (job == null) return const SizedBox.shrink();

    if (job!.items.isEmpty) {
      // show placeholder box but still keep spacing
      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
        child: const Center(child: Text('No items to deliver')),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: ListView.builder(
        itemCount: job!.items.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final item = job!.items[index];
          final product = item.product;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product?.imageUrl != null
                    ? Image.network(product!.imageUrl!, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
                  return Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.broken_image));
                })
                    : Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.inventory_2)),
              ),
              title: Text(item.product?.name ?? 'Product ${item.productId}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('ID: ${item.productId}\nQuantity: x${item.quantity}', style: const TextStyle(height: 1.4)),
              trailing: TextButton(onPressed: () {/* navigate to product details if any */}, child: const Text('view details >')),
            ),
          );
        },
      ),
    );
  }

  // Use VoidCallback for simplicity
  Widget _buildMainButton(String text, VoidCallback onPressed, {Color color = const Color(0xFF2E7D32)}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
        child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(text),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (job == null) return const SizedBox.shrink();

    switch (job!.status) {
      case "pending": // ✅ use assign instead of update
        return _buildMainButton(
          "Pick Up",
              () => _assignJobToCurrentUser(),
        );

      case "picked_up":
        return _buildMainButton(
          "En Route",
              () => _updateJobStatus("en_route"),
        );

      case "en_route":
        return _buildMainButton(
          "Mark as Done",
              () => _simulateImageUpload(), // ✅ proof upload when marking delivered
        );

      case "delivered":
        return Column(
          children: [
            _buildMainButton(
              "Notify",
                  () => _notifyCustomer(),
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            _buildMainButton(
              "View Proof",
                  () => _viewProofImage(),
              color: Colors.green,
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Color _getStatusColor() {
    switch (job?.status.toLowerCase()) {
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

  // ========== build ==========
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // block default back navigation
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, job); // ✅ send updated job back to homepage
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Delivery Detail'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
        body: isLoading && job == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildCustomerInfo(),
              const SizedBox(height: 12),
              _buildProductsList(),
              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}