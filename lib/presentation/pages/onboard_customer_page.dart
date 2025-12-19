import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/dtos/customer_dto.dart';
import '../../domain/dtos/open_account_dto.dart';
import '../../domain/dtos/onboard_customer_dto.dart';
import '../../domain/enums/account_type_enum.dart';
import '../../data/datasource/api_account_data_source.dart';

class OnboardCustomerPage extends StatefulWidget {
  const OnboardCustomerPage({super.key});

  @override
  State<OnboardCustomerPage> createState() => _OnboardCustomerPageState();
}

class _OnboardCustomerPageState extends State<OnboardCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final List<OpenAccountData> _accounts = [];
  final ApiAccountDataSource _dataSource = ApiAccountDataSource();
  bool _isLoading = false;

  // Available account types
  final List<AccountTypeEnum> _availableTypes = [
    AccountTypeEnum.CHECKING,
    AccountTypeEnum.SAVINGS,
    AccountTypeEnum.INVESTMENT,
    AccountTypeEnum.LOAN,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Customer',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Information
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        cursorColor:Colors.teal,
                        decoration: const InputDecoration(
                          labelText: 'Customer Name',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter customer name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor:Colors.teal,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        cursorColor:Colors.teal,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Accounts to be created
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Accounts to be Created',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: Colors.teal),
                            onPressed: _addAccount,
                            tooltip: 'Add Account',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You can add multiple accounts for the customer at the same time',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_accounts.isEmpty)
                        const Center(
                          child: Column(
                            children: [
                              Icon(Icons.account_balance_wallet,
                                  size: 60, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('No accounts added yet'),
                            ],
                          ),
                        )
                      else
                        ..._accounts.asMap().entries.map((entry) {
                          final index = entry.key;
                          final account = entry.value;
                          return _buildAccountCard(index, account);
                        }).toList(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Request Summary
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Request Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Number of Accounts: '),
                          Text(
                            '${_accounts.length}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Account Types: '),
                          Expanded(
                            child: Wrap(
                              spacing: 4,
                              children: _accounts
                                  .map((a) => Chip(
                                label: Text(a.type.englishName),
                                backgroundColor:
                                Colors.teal.withOpacity(0.1),
                              ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Control Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: Get.back,
                      style: OutlinedButton.styleFrom(
                        padding:
                        const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.teal),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.teal),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding:
                        const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Add Customer',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(int index, OpenAccountData account) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.teal.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getTypeIcon(account.type),
                      color: _getTypeColor(account.type),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      account.type.englishName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getTypeColor(account.type),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _removeAccount(index),
                  tooltip: 'Delete Account',
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (account.dailyLimit != null)
              Text('Daily Limit: \$${account.dailyLimit}'),
            if (account.monthlyLimit != null)
              Text('Monthly Limit: \$${account.monthlyLimit}'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _editAccount(index),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.teal,
                minimumSize: const Size(double.infinity, 36),
              ),
              child: const Text('Edit Account',style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }

  void _addAccount() {
    showDialog(
      context: context,
      builder: (context) => _buildAccountDialog(null),
    );
  }

  void _editAccount(int index) {
    showDialog(
      context: context,
      builder: (context) => _buildAccountDialog(_accounts[index], index),
    );
  }

  Widget _buildAccountDialog([OpenAccountData? account, int? index]) {
    final typeController = TextEditingController(
        text: account?.type.value ?? AccountTypeEnum.CHECKING.value);
    final dailyLimitController =
    TextEditingController(text: account?.dailyLimit ?? '');
    final monthlyLimitController =
    TextEditingController(text: account?.monthlyLimit ?? '');

    AccountTypeEnum selectedType =
        account?.type ?? AccountTypeEnum.CHECKING;

    return AlertDialog(
      title: Text(index == null ? 'Add Account' : 'Edit Account',),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<AccountTypeEnum>(
              value: selectedType,
              onChanged: (value) {
                if (value != null) {
                  selectedType = value;
                }
              },
              items: _availableTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        _getTypeIcon(type),
                        color: _getTypeColor(type),
                      ),
                      const SizedBox(width: 8),
                      Text(type.englishName),
                    ],
                  ),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Account Type',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: dailyLimitController,
              keyboardType: TextInputType.number,
              cursorColor: Colors.teal,
              decoration: const InputDecoration(
                labelText: 'Daily Limit (Optional)',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.today),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: monthlyLimitController,
              keyboardType: TextInputType.number,
              cursorColor: Colors.teal,
              decoration: const InputDecoration(
                labelText: 'Monthly Limit (Optional)',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_month),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel',style: TextStyle(color: Colors.teal),),
        ),
        ElevatedButton(
          onPressed: () {
            final newAccount = OpenAccountData(
              type: selectedType,
              dailyLimit: dailyLimitController.text.isNotEmpty
                  ? dailyLimitController.text
                  : null,
              monthlyLimit: monthlyLimitController.text.isNotEmpty
                  ? monthlyLimitController.text
                  : null,
            );

            if (index == null) {
              _accounts.add(newAccount);
            } else {
              _accounts[index] = newAccount;
            }

            setState(() {});
            Navigator.pop(context);
          },
          child: const Text('Save',style:TextStyle(color: Colors.teal)),
        ),
      ],
    );
  }

  void _removeAccount(int index) {
    setState(() {
      _accounts.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_accounts.isEmpty) {
      Get.snackbar(
        'Error',
        'Please add at least one account',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final customer = CustomerData(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      );

      final onboardData = OnboardCustomerData(
        customer: customer,
        accounts: _accounts,
      );

      // Call API
      final result = await _dataSource.onboardCustomer(onboardData);

      // Show success message
      Get.defaultDialog(
        title: 'Operation Successful',
        middleText:
        'Customer has been created and accounts opened successfully.',
        textConfirm: 'OK',
        onConfirm: () {

          // Clear all form data
          _clearForm();
          Get.back(); // Close dialog
          Get.back(); // Go back to previous page
        },
        confirmTextColor: Colors.white,
      );

      // You can update account list or perform other operations here
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add customer: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

// دالة جديدة لتنظيف الحقول
  void _clearForm() {
    // مسح النصوص من الحقول
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();

    // مسح الحسابات المضافة
    _accounts.clear();

    // إعادة تعيين حالة الفورم
    _formKey.currentState?.reset();

    // تحديث الواجهة
    setState(() {});
  }
  IconData _getTypeIcon(AccountTypeEnum type) {
    switch (type) {
      case AccountTypeEnum.SAVINGS:
        return Icons.savings;
      case AccountTypeEnum.CHECKING:
        return Icons.account_balance;
      case AccountTypeEnum.LOAN:
        return Icons.money;
      case AccountTypeEnum.INVESTMENT:
        return Icons.trending_up;
      case AccountTypeEnum.GROUP:
        return Icons.account_tree;
    }
  }

  Color _getTypeColor(AccountTypeEnum type) {
    switch (type) {
      case AccountTypeEnum.SAVINGS:
        return Colors.teal;
      case AccountTypeEnum.CHECKING:
        return Colors.teal;
      case AccountTypeEnum.LOAN:
        return Colors.teal;
      case AccountTypeEnum.INVESTMENT:
        return Colors.teal;
      case AccountTypeEnum.GROUP:
        return Colors.teal;
    }
  }

}