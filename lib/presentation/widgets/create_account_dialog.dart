import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/enums/account_type_enum.dart';

class CreateAccountDialog extends StatefulWidget {
  final Function({
  required AccountTypeEnum type,
  String? dailyLimit,
  String? monthlyLimit,
  }) onCreate;

  const CreateAccountDialog({super.key, required this.onCreate,
  });

  @override
  State<CreateAccountDialog> createState() => _CreateAccountDialogState();
}

class _CreateAccountDialogState extends State<CreateAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  AccountTypeEnum? _selectedType;
  final TextEditingController _dailyLimitController = TextEditingController();
  final TextEditingController _monthlyLimitController = TextEditingController();

  final List<AccountTypeEnum> _availableTypes = [
    AccountTypeEnum.SAVINGS,
    AccountTypeEnum.INVESTMENT,
    AccountTypeEnum.LOAN,
    AccountTypeEnum.CHECKING,
  ];

  @override
  void dispose() {
    _dailyLimitController.dispose();
    _monthlyLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Create New Account',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Account Type
              DropdownButtonFormField<AccountTypeEnum>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Account Type',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.account_balance, color: Colors.grey.shade600),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                ),
                items: _availableTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.englishName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select account type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Daily Limit
              TextFormField(
                controller: _dailyLimitController,
                cursorColor: Colors.teal,
                decoration: InputDecoration(
                  labelText: 'Daily Limit (Optional)',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.today, color: Colors.grey.shade600),
                    suffixText: '\$',
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final num = double.tryParse(value);
                    if (num == null) {
                      return 'Please enter a valid number';
                    }
                    if (num <= 0) {
                      return 'Number must be greater than zero';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Monthly Limit
              TextFormField(
                controller: _monthlyLimitController,
                cursorColor: Colors.teal,
                decoration: InputDecoration(
                  labelText: 'Monthly Limit (Optional)',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.calendar_today, color: Colors.grey.shade600),
                    suffixText: '\$',
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final num = double.tryParse(value);
                    if (num == null) {
                      return 'Please enter a valid number';
                    }
                    if (num <= 0) {
                      return 'Number must be greater than zero';
                    }

                    // Check if daily limit exists
                    if (_dailyLimitController.text.isNotEmpty) {
                      final daily = double.tryParse(_dailyLimitController.text) ?? 0;
                      if (num < daily) {
                        return 'Monthly limit must be greater than daily limit';
                      }
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),

              // Information Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notes:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Account will be created under the current user',
                      style: TextStyle(fontSize: 12),
                    ),
                    const Text(
                      '• Account will be active immediately after creation',
                      style: TextStyle(fontSize: 12),
                    ),
                    const Text(
                      '• You can modify limits later',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          style: TextButton.styleFrom(
            foregroundColor: Colors.teal,
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onCreate(
                type: _selectedType!,
                dailyLimit: _dailyLimitController.text.isNotEmpty
                    ? _dailyLimitController.text
                    : null,
                monthlyLimit: _monthlyLimitController.text.isNotEmpty
                    ? _monthlyLimitController.text
                    : null,
              );
              Get.back();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          child: const Text('Create'),
        ),
      ],
    );
  }
}