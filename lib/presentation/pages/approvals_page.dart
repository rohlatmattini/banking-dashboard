import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction_entity.dart';
import '../controller/approval_controller.dart';

class ApprovalsPage extends StatelessWidget {
  final ApprovalController controller = Get.find<ApprovalController>();

  ApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pending Approvals',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal[700],
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => Badge(
            label: Text(controller.pendingCount.toString()),
            backgroundColor: Colors.red,
            isLabelVisible: controller.pendingCount > 0,
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: controller.fetchPendingApprovals,
              tooltip: 'Refresh',
            ),
          )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.teal),
                SizedBox(height: 16),
                Text('Loading pending approvals...'),
              ],
            ),
          );
        }

        if (controller.pendingApprovals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 100,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 20),
                const Text(
                  'No Pending Approvals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'All transactions have been reviewed',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: controller.fetchPendingApprovals,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchPendingApprovals,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.pendingApprovals.length,
            itemBuilder: (context, index) {
              final transaction = controller.pendingApprovals[index];
              return _buildTransactionCard(transaction);
            },
          ),
        );
      }),
    );
  }

  Widget _buildTransactionCard(TransactionEntity transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    transaction.type.value.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: _getTypeColor(transaction.type),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                ),
                Text(
                  '\$${transaction.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),

            // Transaction Details
            _buildDetailRow('Transaction ID:', transaction.publicId),
            _buildDetailRow('Description:', transaction.description),
            _buildDetailRow('Initiated:', _formatDate(transaction.createdAt)),

            if (transaction.sourceAccountId != null)
              _buildDetailRow('From Account:', transaction.sourceAccountId.toString()),
            if (transaction.destinationAccountId != null)
              _buildDetailRow('To Account:', transaction.destinationAccountId.toString()),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Decision Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDecisionDialog(transaction, 'reject'),
                    icon: const Icon(Icons.close, size: 20),
                    label: const Text(
                      'Reject',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDecisionDialog(transaction, 'approve'),
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text(
                      'Approve',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    return DateFormat('MMM dd, yyyy • HH:mm').format(date!);
  }

  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.DEPOSIT:
        return Colors.teal;
      case TransactionType.WITHDRAW:
        return Colors.teal;
      case TransactionType.TRANSFER:
        return Colors.teal;
      default:
        return Colors.teal;
    }
  }

  void _showDecisionDialog(TransactionEntity transaction, String decision) {
    final noteController = TextEditingController();
    final isApprove = decision == 'approve';

    Get.dialog(
      AlertDialog(
        title: Text(
          '${isApprove ? 'approve' : 'Reject'} Transaction?',
          style: TextStyle(color: isApprove ? Colors.teal : Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount: \$${transaction.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('"${transaction.description}"'),
            const SizedBox(height: 16),
            const Text(
              'Add a note (optional):',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: isApprove ? 'e.g., Approved per policy...' : 'e.g., Reason for rejection...',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(12),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isProcessingDecision.value
                ? null
                : () async {
              await controller.submitDecision(
                transaction.publicId,
                decision,
                noteController.text.isNotEmpty ? noteController.text : null,
              );
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? Colors.teal : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: controller.isProcessingDecision.value
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Text(isApprove ? 'Confirm Approval' : 'Confirm Rejection'),
          )),
        ],
      ),
    );
  }
}