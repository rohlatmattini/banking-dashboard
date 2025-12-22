import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/ledger_entry_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../controller/approval_controller.dart';
import '../controller/transaction_controller.dart';

class TransactionsPage extends StatelessWidget {
  final TransactionController controller = Get.find<TransactionController>();

  TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Colors.teal[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.toNamed('/'),
        ),
        actions: [
          Builder(
            builder: (context) {
              try {
                final approvalController = Get.find<ApprovalController>();
                return Badge(
                  label: Text(approvalController.pendingCount.toString()),
                  backgroundColor: Colors.red,
                  isLabelVisible: approvalController.pendingCount > 0,
                  child: IconButton(
                    icon: const Icon(Icons.gavel, color: Colors.white),
                    onPressed: () => Get.toNamed('/approvals'),
                    tooltip: 'Pending Approvals',
                  ),
                );
              } catch (e) {
                return IconButton(
                  icon: const Icon(Icons.gavel, color: Colors.white),
                  onPressed: () => Get.toNamed('/approvals'),
                  tooltip: 'Pending Approvals',
                );
              }
            },
          ),

          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onSelected: (value) {
              controller.changeTypeFilter(value);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'all', child: Text('All Types')),
              PopupMenuItem(value: 'deposit', child: Text('Deposits')),
              PopupMenuItem(value: 'withdraw', child: Text('Withdrawals')),
              PopupMenuItem(value: 'transfer', child: Text('Transfers')),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.teal));
        }

        final transactions = controller.filteredTransactions;

        if (transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No transactions',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                if (controller.transactionTypeFilter.value != 'all')
                  ElevatedButton(
                    onPressed: () => controller.changeTypeFilter('all'),
                    child: const Text('Clear Filter'),
                  ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return _buildTransactionCard(transaction);
          },
        );
      }),
    );
  }

  Widget _buildTransactionCard(TransactionEntity transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: controller.getTransactionColor(transaction.type.value),
          child: Text(
            controller.getTransactionTypeIcon(transaction.type.value),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'ID: ${transaction.publicId}',
              style: const TextStyle(fontSize: 11),
            ),
            const SizedBox(height: 2),
            Text(
              'Date: ${transaction.postedAt != null
                  ? DateFormat('MMM dd, yyyy HH:mm').format(transaction.postedAt!)
                  : '—'}',
            )

              ],
        ),
        trailing: SizedBox(
          width: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 1),
              Chip(
                label: Text(
                  transaction.status.value.toUpperCase(),
                  style: const TextStyle(fontSize: 10),
                ),
                backgroundColor: _getStatusColor(transaction.status),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.POSTED:
        return Colors.teal.withOpacity(0.2);
      case TransactionStatus.PENDING:
        return Colors.teal.withOpacity(0.2);
      case TransactionStatus.FAILED:
        return Colors.teal.withOpacity(0.2);
      default:
        return Colors.teal.withOpacity(0.2);
    }
  }

  void _showTransactionDetails(TransactionEntity transaction) {
    controller.fetchTransactionDetail(transaction.publicId);
    Get.dialog(
      AlertDialog(
        title: const Text('Transaction Details'),
        content: Obx(() {
          final detail = controller.selectedTransaction.value;
          if (detail == null) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator(color: Colors.teal,)),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Type', detail.type.value.toUpperCase()),
                _buildDetailRow('Status', detail.status.value.toUpperCase()),
                _buildDetailRow('Amount', '\$${detail.amount.toStringAsFixed(2)}'),
                _buildDetailRow('Currency', detail.currency),
                _buildDetailRow('Description', detail.description),
                _buildDetailRow(
                  'Date',
                  detail.postedAt != null
                      ? DateFormat('MMMM dd, yyyy HH:mm:ss').format(detail.postedAt!)
                      : '—',
                ),
                _buildDetailRow(
                  'createdAt',
                  detail.postedAt != null
                      ? DateFormat('MMMM dd, yyyy HH:mm:ss').format(detail.createdAt)
                      : '—',
                ),

                if (detail.ledgerEntries.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Ledger Entries',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Divider(),
                  ...detail.ledgerEntries.map((entry) => _buildLedgerEntry(entry)).toList(),
                ],
              ],
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Close',style: TextStyle(color: Colors.teal),),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerEntry(LedgerEntryEntity entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Account: ${entry.accountPublicId}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(
                  label: Text(
                    entry.direction.value.toUpperCase(),
                    style: TextStyle(
                      color: entry.direction == EntryDirection.DEBIT ? Colors.red : Colors.teal,
                      fontSize: 10,
                    ),
                  ),
                  backgroundColor: entry.direction == EntryDirection.DEBIT
                      ? Colors.red.withOpacity(0.1)
                      : Colors.teal.withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount: \$${entry.amount.toStringAsFixed(2)}'),
                      Text('Before: \$${entry.balanceBefore.toStringAsFixed(2)}'),
                      Text('After: \$${entry.balanceAfter.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
                Icon(
                  entry.direction == EntryDirection.DEBIT ? Icons.arrow_downward : Icons.arrow_upward,
                  color: entry.direction == EntryDirection.DEBIT ? Colors.red : Colors.teal,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Date: ${DateFormat('MM/dd HH:mm').format(entry.createdAt)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}