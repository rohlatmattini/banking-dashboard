import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/approval_controller.dart';
import '../controller/enhanced_account_controller.dart';
import '../widgets/user_account_card.dart';
import '../pages/onboard_customer_page.dart';

class AccountManagementPage extends StatelessWidget {
  final EnhancedAccountController controller = Get.find<EnhancedAccountController>();

  AccountManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Accounts',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal[700],
        elevation: 2,
        leading:   IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.toNamed('/'),

        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () => Get.toNamed('/accounts/onboard'),
            tooltip: 'Add New Customer',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.fetchUsersWithAccounts(),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.account_tree, color: Colors.white),
            onPressed: () => Get.toNamed('/accounts/hierarchy'),
            tooltip: 'View Account Hierarchy',
          ),
          // In AccountManagementPage AppBar actions:
          Obx(() {
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
          }),

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
                Text('Loading users and accounts...'),
              ],
            ),
          );
        }

        if (controller.usersWithAccounts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people,
                  size: 100,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 20),
                const Text(
                  'No users found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Add a new customer to get started',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return _AccountManagementContent();
      }),
    );
  }
}

class _AccountManagementContent extends StatefulWidget {
  const _AccountManagementContent();

  @override
  State<_AccountManagementContent> createState() => _AccountManagementContentState();
}

class _AccountManagementContentState extends State<_AccountManagementContent> {
  String _searchQuery = '';
  int _selectedFilter = -1;

  List<Map<String, dynamic>> get filteredUsers {
    final controller = Get.find<EnhancedAccountController>();
    var filtered = controller.usersWithAccounts.toList();

    // Filter by search text
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        final name = (user['name'] ?? '').toString().toLowerCase();
        final email = (user['email'] ?? '').toString().toLowerCase();
        final phone = (user['phone'] ?? '').toString().toLowerCase();

        return name.contains(_searchQuery.toLowerCase()) ||
            email.contains(_searchQuery.toLowerCase()) ||
            phone.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by account count
    if (_selectedFilter != -1) {
      filtered = filtered.where((user) {
        final accounts = List<Map<String, dynamic>>.from(user['accounts'] ?? []);
        return accounts.length == _selectedFilter;
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnhancedAccountController >();
    final usersToShow = filteredUsers;

    return Column(
      children: [
        // Search and Filters
        _buildSearchAndFilters(),

        // Statistics
        _buildOverallStatistics(),

        // Users List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await controller.fetchUsersWithAccounts();
            },
            child: usersToShow.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _searchQuery.isNotEmpty || _selectedFilter != -1
                        ? Icons.search_off
                        : Icons.people,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    usersToShow.isEmpty && controller.usersWithAccounts.isNotEmpty
                        ? 'No matching users found'
                        : 'No users',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_searchQuery.isNotEmpty || _selectedFilter != -1)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _selectedFilter = -1;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Clear Filters'),
                    ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: usersToShow.length,
              itemBuilder: (context, index) {
                final user = usersToShow[index];
                return UserAccountCard(
                  userData: user,
                  controller: controller,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          TextField(
            cursorColor: Colors.teal,
            decoration: InputDecoration(
              hintText: 'Search by name, email, or phone...',
              prefixIcon: const Icon(Icons.search, color: Colors.teal),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Users'),
                  selected: _selectedFilter == -1,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? -1 : _selectedFilter;
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: Colors.teal,
                  labelStyle: TextStyle(
                    color: _selectedFilter == -1 ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                ...List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('$index Account${index != 1 ? 's' : ''}'),
                      selected: _selectedFilter == index,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = selected ? index : -1;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Colors.teal,
                      labelStyle: TextStyle(
                        color: _selectedFilter == index ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }),
                FilterChip(
                  label: const Text('5+ Accounts'),
                  selected: _selectedFilter == 5,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? 5 : -1;
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: Colors.teal,
                  labelStyle: TextStyle(
                    color: _selectedFilter == 5 ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStatistics() {
    final controller = Get.find<EnhancedAccountController>(); // Changed from AccountController
    int totalUsers = controller.usersWithAccounts.length;
    int totalAccounts = 0;
    int activeAccounts = 0;

    for (var user in controller.usersWithAccounts) {
      final accounts = List<Map<String, dynamic>>.from(user['accounts'] ?? []);
      totalAccounts += accounts.length;

      for (var account in accounts) {
        if ((account['state'] as String? ?? 'active') == 'active') {
          activeAccounts++;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(0),
      color: Colors.teal[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildOverallStatItem('Total Users', totalUsers.toString()),
          _buildOverallStatItem('Total Accounts', totalAccounts.toString()),
          _buildOverallStatItem('Active Accounts', activeAccounts.toString()),
        ],
      ),
    );
  }

  Widget _buildOverallStatItem(String label, String value) {
    return Column(
      children: [

        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}