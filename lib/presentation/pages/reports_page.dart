// lib/presentation/pages/reports_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/report_controller.dart';

class ReportsPage extends StatelessWidget {
  final ReportController controller = Get.find<ReportController>();

  ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: Colors.teal[700],
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.toNamed('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.loadAllReports,
            tooltip: 'Refresh Reports',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.teal));
        }

        return RefreshIndicator(
          onRefresh: controller.loadAllReports,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Date Picker

              const SizedBox(height: 20),

              // System Summary
              _buildSystemSummary(),
              const SizedBox(height: 20),

              // Daily Transactions Report
              _buildDailyTransactions(),
              const SizedBox(height: 20),

              // Audit Logs
              _buildAuditLogs(),
            ],
          ),
        );
      }),
    );
  }


  Widget _buildSystemSummary() {
    final summary = controller.systemSummary.value;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              children: [
                _buildSummaryItem('Date', summary['date'] ?? 'N/A', Icons.calendar_today),
                _buildSummaryItem('Audit Logs', (summary['audit_logs_count'] ?? 0).toString(), Icons.history),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTransactions() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (controller.dailyReports.isEmpty)
              const Center(child: Text('No transactions for selected date')),
            ...controller.dailyReports.map((transaction) => _buildTransactionItem(transaction)),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditLogs() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Logs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (controller.auditLogs.isEmpty)
              const Center(child: Text('No audit logs available')),
            ...controller.auditLogs.map((log) => _buildAuditLogItem(log)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction['type'].toString().toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                transaction['status'].toString().toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  color: _getStatusColor(transaction['status']),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${transaction['total_amount']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              Text(
                '${transaction['count']} transactions',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogItem(Map<String, dynamic> log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                log['action'].toString().split('.').last.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                _formatTime(log['created_at']),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'User: ${log['actor_user_id']} (${log['actor_role']})',
            style: const TextStyle(fontSize: 12),
          ),
          if (log['meta'] != null && (log['meta'] as Map).containsKey('email'))
            Text(
              'Email: ${(log['meta'] as Map)['email']}',
              style: const TextStyle(fontSize: 12),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'posted':
        return Colors.teal;
      case 'pending':
        return Colors.teal;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      return DateFormat('MM/dd HH:mm').format(date);
    } catch (e) {
      return dateTime;
    }
  }
}