import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/enums/account_type_enum.dart';
import '../../domain/dtos/open_account_dto.dart';
import '../controller/enhanced_account_controller.dart';
import '../widgets/create_account_dialog.dart';
import '../helpers/state_helper.dart';

class UserAccountCard extends StatelessWidget {
  final Map<String, dynamic> userData;
  final EnhancedAccountController  controller;

  const UserAccountCard({
    super.key,
    required this.userData,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final accounts = List<Map<String, dynamic>>.from(userData['accounts'] ?? []);
    final stats = controller.getUserStatistics(userData);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfo(),
            const Divider(height: 20),

            _buildStatistics(stats),
            const Divider(height: 20),

            _buildAddAccountButton(),

            if (accounts.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildAccountsList(accounts),
            ] else ...[
              const SizedBox(height: 16),
              _buildNoAccounts(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: Colors.teal[100],
          child: Icon(
            Icons.person,
            color: Colors.teal[700],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userData['name'] ?? 'No Name',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userData['email'] ?? 'No Email',
                style: TextStyle(color: Colors.grey[600]),
              ),
              if (userData['phone'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Phone: ${userData['phone']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.fingerprint, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'User ID: ${userData['id']}',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(Map<String, int> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Statistics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatItem('Total', stats['total'] ?? 0, Colors.teal),
            _buildStatItem('Active', stats['active'] ?? 0, Colors.green),
            _buildStatItem('Frozen', stats['frozen'] ?? 0, Colors.blue),
            _buildStatItem('Closed', stats['closed'] ?? 0, Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildAddAccountButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: () => _showCreateAccountDialog(),
        icon: const Icon(Icons.add_circle, size: 16),
        label: const Text('Add Account'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
      ),
    );
  }

  Widget _buildAccountsList(List<Map<String, dynamic>> accounts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Accounts',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        ...accounts.map((account) => _buildAccountItem(account)).toList(),
      ],
    );
  }

  Widget _buildAccountItem(Map<String, dynamic> account) {
    final state = account['state'] as String? ?? 'active';
    final stateColor = StateHelper.getColorForStateName(state);
    final stateIcon = StateHelper.getIconForStateName(state);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          // Account Type Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _getTypeColor(account['type']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              _getTypeIcon(account['type']),
              color: _getTypeColor(account['type']),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),

          // Account Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getTypeName(account['type']),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: stateColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: stateColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(stateIcon, size: 10, color: stateColor),
                          const SizedBox(width: 4),
                          Text(
                            state.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: stateColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${account['public_id']}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Balance: \$${account['balance'] ?? '0.00'}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                if (account['daily_limit'] != null || account['monthly_limit'] != null) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (account['daily_limit'] != null)
                        Text(
                          'Daily: \$${account['daily_limit']}',
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      if (account['monthly_limit'] != null)
                        Text(
                          'Monthly: \$${account['monthly_limit']}',
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Actions
          IconButton(
            icon: const Icon(Icons.more_vert, size: 18),
            onPressed: () => _showTransactionMenu(account),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAccounts() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 8),
          const Text(
            'No accounts yet',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            'Click "Add Account" to create the first account',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showCreateAccountDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) => CreateAccountDialog(
        onCreate: ({
          required AccountTypeEnum type,
          String? dailyLimit,
          String? monthlyLimit,
        }) {
          final dto = OpenAccountData(
            type: type,
            dailyLimit: dailyLimit,
            monthlyLimit: monthlyLimit,
          );

          controller.createUserAccount(userData['id'], dto);
        },
      ),
    );
  }

  void _showTransactionMenu(Map<String, dynamic> account) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Account Operations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
          
              // Deposit Button
              ListTile(
                leading: const Icon(Icons.add_circle, color: Colors.teal),
                title: const Text('Deposit'),
                subtitle: const Text('Add money to account'),
                onTap: () {
                  Get.back();
                  _showDepositDialog(account);
                },
              ),
          
              // Withdraw Button
              ListTile(
                leading: const Icon(Icons.remove_circle, color: Colors.teal),
                title: const Text('Withdraw'),
                subtitle: const Text('Withdraw money from account'),
                onTap: () {
                  Get.back();
                  _showWithdrawDialog(account);
                },
              ),
          
              // Transfer Button
              ListTile(
                leading: const Icon(Icons.swap_horiz, color: Colors.teal),
                title: const Text('Transfer'),
                subtitle: const Text('Transfer to another account'),
                onTap: () {
                  Get.back();
                  _showTransferDialog(account);
                },
              ),
          
              // Change State Button
              ListTile(
                leading: const Icon(Icons.sync, color: Colors.teal),
                title: const Text('Change State'),
                subtitle: const Text('Change account status'),
                onTap: () {
                  Get.back();
                  _showStateChangeDialog(account);
                },
              ),
          
              // View Details Button
              ListTile(
                leading: const Icon(Icons.info, color: Colors.teal),
                title: const Text('View Details'),
                subtitle: const Text('View account details'),
                onTap: () {
                  Get.back();
                  _showAccountDetails(account);
                },
              ),

            ],
          ),
        ),
      ),
    );
  }

  void _showStateChangeDialog(Map<String, dynamic> account) {
    final availableStates = ['active', 'frozen', 'suspended', 'closed'];

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Change Account State',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Account: ${_getTypeName(account['type'])}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...availableStates.map((state) => ListTile(
              leading: Icon(
                _getStateIcon(state),
                color: _getStateColor(state),
              ),
              title: Text(state.toUpperCase()),
              trailing: account['state'] == state
                  ? const Icon(Icons.check, color: Colors.teal)
                  : null,
              onTap: () {
                Get.back();
                controller.changeAccountState(account['public_id'], state);
              },
            )).toList(),
          ],
        ),
      ),
    );
  }

  void _showDepositDialog(Map<String, dynamic> account) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text('Deposit'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Account: ${_getTypeName(account['type'])}',
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                'Current Balance: \$${account['balance'] ?? '0.00'}',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                cursorColor: Colors.grey,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),

                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                cursorColor: Colors.grey,
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel',style: TextStyle(color: Colors.teal),),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final amount = double.parse(amountController.text);
                final description = descriptionController.text;

                Get.back();
                controller.deposit(
                  accountPublicId: account['public_id'],
                  amount: amount,
                  description: description.isNotEmpty ? description : 'Deposit',
                );
              }
            },

            child: const Text('Deposit',style: TextStyle(color: Colors.teal),),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(Map<String, dynamic> account) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text('Withdraw'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Account: ${_getTypeName(account['type'])}',
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                'Current Balance: \$${account['balance'] ?? '0.00'}',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                cursorColor: Colors.grey,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount greater than zero';
                    }

                  // Check sufficient balance
                  final balance = double.tryParse(account['balance']?.toString() ?? '0') ?? 0.0;
        if (amount > balance) {
      return 'Amount exceeds available balance';
    }
                    // Check daily limit (if exists)
                    final dailyLimit = account['daily_limit'] != null
                        ? double.tryParse(account['daily_limit'])
                        : null;
                    if (dailyLimit != null && amount > dailyLimit) {
                      return 'Amount exceeds daily limit (\$${dailyLimit.toStringAsFixed(2)})';
                    }

                    return null;
                  },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descriptionController,
                cursorColor: Colors.grey,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel',style: TextStyle(color: Colors.teal),),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final amount = double.parse(amountController.text);
                final description = descriptionController.text;

                Get.back();
                controller.withdraw(
                  accountPublicId: account['public_id'],
                  amount: amount,
                  description: description.isNotEmpty ? description : 'Withdrawal',
                );
              }
            },

            child: const Text('Withdraw',style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog(Map<String, dynamic> sourceAccount) {
    final amountController = TextEditingController();
    final destinationController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text('Transfer'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'From: ${_getTypeName(sourceAccount['type'])}',
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                'Balance: \$${sourceAccount['balance'] ?? '0.00'}',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: destinationController,
                cursorColor: Colors.grey,
                decoration: const InputDecoration(
                  labelText: 'Destination Account ID',
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.account_balance),
                  hintText: 'Enter account public ID',
                    hintStyle: TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey))

                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter destination account ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amountController,
                cursorColor: Colors.grey,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.attach_money),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey))
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel',style: TextStyle(color: Colors.teal)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final amount = double.parse(amountController.text);
                final description = descriptionController.text;

                Get.back();
                controller.transfer(
                  sourceAccountPublicId: sourceAccount['public_id'],
                  destinationAccountPublicId: destinationController.text,
                  amount: amount,
                  description: description.isNotEmpty ? description : 'Transfer',
                );
              }
            },

            child: const Text('Transfer',style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  void _showAccountDetails(Map<String, dynamic> account) {
    Get.dialog(
      AlertDialog(
        title: const Text('Account Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Account Type', _getTypeName(account['type'])),
              _buildDetailItem('Account ID', account['public_id'] ?? 'N/A'),
              _buildDetailItem('State', (account['state'] as String? ?? 'active').toUpperCase()),
              _buildDetailItem('Balance', '\$${account['balance'] ?? '0.00'}'),
              if (account['daily_limit'] != null)
                _buildDetailItem('Daily Limit', '\$${account['daily_limit']}'),
              if (account['monthly_limit'] != null)
                _buildDetailItem('Monthly Limit', '\$${account['monthly_limit']}'),
              if (account['parent_public_id'] != null)
                _buildDetailItem('Parent Account', account['parent_public_id']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Close',style: TextStyle(color: Colors.teal),),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'savings':
        return Icons.savings;
      case 'checking':
        return Icons.account_balance;
      case 'loan':
        return Icons.money;
      case 'investment':
        return Icons.trending_up;
      case 'group':
        return Icons.account_tree;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'savings':
        return Colors.teal;
      case 'checking':
        return Colors.teal;
      case 'loan':
        return Colors.teal;
      case 'investment':
        return Colors.teal;
      case 'group':
        return Colors.teal;
      default:
        return Colors.teal;
    }
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'savings':
        return 'Savings Account';
      case 'checking':
        return 'Checking Account';
      case 'loan':
        return 'Loan Account';
      case 'investment':
        return 'Investment Account';
      case 'group':
        return 'Group Account';
      default:
        return 'Account';
    }
  }

  IconData _getStateIcon(String state) {
    switch (state) {
      case 'active':
        return Icons.check_circle;
      case 'frozen':
        return Icons.ac_unit;
      case 'suspended':
        return Icons.pause_circle;
      case 'closed':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getStateColor(String state) {
    switch (state) {
      case 'active':
        return Colors.teal;
      case 'frozen':
        return Colors.teal;
      case 'suspended':
        return Colors.teal;
      case 'closed':
        return Colors.red;
      default:
        return Colors.teal;
    }
  }
}