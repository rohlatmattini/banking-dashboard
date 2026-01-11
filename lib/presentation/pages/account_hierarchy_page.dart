// lib/presentation/pages/account_hierarchy_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bankingplatform/domain/entities/account_entity.dart';
import 'package:bankingplatform/domain/patterns/composite/account_component.dart';
import 'package:bankingplatform/domain/patterns/composite/account_group.dart';
import 'package:bankingplatform/domain/patterns/composite/account_leaf.dart';
import 'package:bankingplatform/presentation/controller/enhanced_account_controller.dart';
import 'package:bankingplatform/domain/enums/account_type_enum.dart';

import '../../domain/patterns/states/account_state_factory.dart';
import '../../domain/services/account_tree_builder.dart';

class AccountHierarchyPage extends StatefulWidget {
  const AccountHierarchyPage({super.key});

  @override
  State<AccountHierarchyPage> createState() => _AccountHierarchyPageState();
}

class _AccountHierarchyPageState extends State<AccountHierarchyPage> {
  final EnhancedAccountController controller = Get.find<EnhancedAccountController>();
  final AccountTreeBuilder _treeBuilder = AccountTreeBuilder();

  final _expandedNodes = <String>{}.obs;
  final _isLoading = false.obs;
  List<AccountComponent> _hierarchies = [];

  @override
  void initState() {
    super.initState();
    _loadHierarchies();
  }

  Future<void> _loadHierarchies() async {
    _isLoading.value = true;
    try {
      final users = controller.usersWithAccounts;
      print('🔍 Total users: ${users.length}');

      _hierarchies.clear();

      for (var user in users) {
        print('🔍 Processing user: ${user['name']}');
        final accounts = await _convertUserDataToAccounts(user);
        print('🔍 User accounts count: ${accounts.length}');

        if (accounts.isNotEmpty) {
          final hierarchy = _treeBuilder.buildForUser(accounts);
          print('🔍 Hierarchy built - Children: ${hierarchy.children().length}');
          _hierarchies.add(hierarchy);
        } else {
          print('⚠️ No accounts for user: ${user['name']}');
        }
      }

      print('✅ Total hierarchies: ${_hierarchies.length}');
    } catch (e, stack) {
      print('❌ Error loading hierarchies: $e');
      print('Stack trace: $stack');
      Get.snackbar(
        'Error',
        'Failed to load account hierarchies: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<List<AccountEntity>> _convertUserDataToAccounts(Map<String, dynamic> userData) async {
    print('🔄 Converting user data for: ${userData['name']}');

    final accounts = List<Map<String, dynamic>>.from(userData['accounts'] ?? []);
    print('📊 Raw accounts count: ${accounts.length}');

    final Map<String, int> publicIdToTempId = {};
    int tempIdCounter = 1;
    final List<Map<String, dynamic>> processedAccounts = [];

    for (var i = 0; i < accounts.length; i++) {
      var accountData = accounts[i];
      final publicId = accountData['public_id']?.toString() ?? 'temp_$i';

      if (!publicIdToTempId.containsKey(publicId)) {
        publicIdToTempId[publicId] = tempIdCounter++;
      }

      final processed = Map<String, dynamic>.from(accountData);
      processed['temp_id'] = publicIdToTempId[publicId];
      processedAccounts.add(processed);
    }

    for (var accountData in processedAccounts) {
      final parentPublicId = accountData['parent_public_id']?.toString();
      if (parentPublicId != null && parentPublicId.isNotEmpty) {
        accountData['parent_id'] = publicIdToTempId[parentPublicId];
      } else {
        accountData['parent_id'] = null;
      }
    }

    final List<AccountEntity> accountEntities = [];

    for (var i = 0; i < processedAccounts.length; i++) {
      var accountData = processedAccounts[i];
      print('🔧 Processing account $i: $accountData');

      try {
        final account = _createAccountEntity(accountData, userData);
        accountEntities.add(account);
        print('✅ Successfully created account: ${account.publicId}');
      } catch (e, stack) {
        print('❌ Error creating account $i: $e');
        print('Stack trace: $stack');
        print('Problematic data: $accountData');
      }
    }

    print('🎯 Total converted accounts: ${accountEntities.length}');
    return accountEntities;
  }

  AccountEntity _createAccountEntity(Map<String, dynamic> accountData, Map<String, dynamic> userData) {
    final id = accountData['temp_id'] ?? accountData['id'] ?? 0;
    final publicId = accountData['public_id']?.toString() ?? 'acc_${DateTime.now().millisecondsSinceEpoch}';
    final typeStr = accountData['type']?.toString() ?? 'checking';

    print('🔧 Creating account - ID: $id, PublicID: $publicId, Type: $typeStr, ParentID: ${accountData['parent_id']}');

    return AccountEntity(
      id: id is int ? id : int.tryParse(id.toString()) ?? 0,
      publicId: publicId,
      userId: userData['id'] is int ? userData['id'] : int.tryParse(userData['id']?.toString() ?? '0') ?? 0,
      parentId: accountData['parent_id'] is int
          ? accountData['parent_id']
          : int.tryParse(accountData['parent_id']?.toString() ?? ''),
      type: AccountTypeEnum.fromValue(typeStr),
      balance: _parseDouble(accountData['balance']),
      state: AccountStateFactory.from(accountData['state']?.toString() ?? 'active'),
      dailyLimit: accountData['daily_limit']?.toString(),
      monthlyLimit: accountData['monthly_limit']?.toString(),
      closedAt: accountData['closed_at'] != null
          ? DateTime.tryParse(accountData['closed_at'].toString())
          : null,
      createdAt: DateTime.parse(accountData['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(accountData['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
      userName: userData['name']?.toString(),
      userEmail: userData['email']?.toString(),
      userPhone: userData['phone']?.toString(),
    );
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;

      final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }
  double get totalAllGroupsBalance {
    double total = 0;
    for (var hierarchy in _hierarchies) {
      total += double.parse(hierarchy.totalBalance());
    }
    return total;
  }

  int get totalAccountsCount {
    int count = 0;
    for (var hierarchy in _hierarchies) {
      count += _countAccountsInHierarchy(hierarchy);
    }
    return count;
  }

  int _countAccountsInHierarchy(AccountComponent component) {
    int count = 1;
    for (var child in component.children()) {
      count += _countAccountsInHierarchy(child);
    }
    return count;
  }

  void _toggleNode(String nodeId) {
    if (_expandedNodes.contains(nodeId)) {
      _expandedNodes.remove(nodeId);
    } else {
      _expandedNodes.add(nodeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Hierarchy'),
        backgroundColor: Colors.teal[700],
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.toNamed('/accounts'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadHierarchies,
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'export') {
                _exportHierarchy();
              } else if (value == 'stats') {
                _showStatistics();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Export Hierarchy'),
                ),
              ),
              PopupMenuItem(
                value: 'stats',
                child: ListTile(
                  leading: Icon(Icons.analytics),
                  title: Text('View Statistics'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.teal),
                SizedBox(height: 16),
                Text('Loading account hierarchies...'),
              ],
            ),
          );
        }

        if (_hierarchies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_tree,
                  size: 100,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 20),
                const Text(
                  'No Account Hierarchies',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Add accounts to users to see hierarchical structure',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loadHierarchies,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Header Statistics
            _buildHeaderStatistics(),
            const Divider(height: 1),

            // Hierarchy List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _hierarchies.length,
                itemBuilder: (context, index) {
                  final hierarchy = _hierarchies[index];
                  return _buildHierarchyCard(hierarchy, index);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeaderStatistics() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.teal[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Groups', _hierarchies.length.toString(), Icons.group),
          _buildStatItem('Accounts', totalAccountsCount.toString(), Icons.account_balance_wallet),
          _buildStatItem('Total Balance', '\$${totalAllGroupsBalance.toStringAsFixed(2)}', Icons.attach_money),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.teal.withOpacity(0.3)),
          ),
          child: Center(
            child: Icon(icon, color: Colors.teal, size: 24),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildHierarchyCard(AccountComponent hierarchy, int index) {
    final userName = _getUserNameFromHierarchy(hierarchy);
    final isExpanded = _expandedNodes.contains('hierarchy_$index');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Column(
        children: [
          // Header
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal[100],
              child: Icon(
                Icons.person,
                color: Colors.teal[700],
              ),
            ),
            title: Text(
              userName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Total: \$${hierarchy.totalBalance()} | ${_countAccountsInHierarchy(hierarchy)} accounts',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: IconButton(
              icon: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.teal,
              ),
              onPressed: () => _toggleNode('hierarchy_$index'),
            ),
            onTap: () => _toggleNode('hierarchy_$index'),
          ),

          // Expandable Content
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildHierarchyTree(hierarchy, 0),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHierarchyTree(AccountComponent node, int level) {
    final indent = level * 20.0;
    final isGroup = node.children().isNotEmpty;
    final isExpanded = _expandedNodes.contains(node.publicId());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: indent),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isGroup ? Colors.teal[50] : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isGroup ? Colors.teal.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isGroup ? Icons.account_tree : Icons.account_balance_wallet,
                color: isGroup ? Colors.teal : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${node.type().toUpperCase()}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isGroup ? Colors.teal : Colors.black,
                            ),
                          ),
                        ),
                        Text(
                          '\$${node.totalBalance()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ID: ${node.publicId()}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (isGroup)
                          Chip(
                            label: Text(
                              '${node.children().length} accounts',
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: Colors.teal.withOpacity(0.1),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          ),
                      ],
                    ),
                    Text(
                      'State: ${node.state()}',
                      style: TextStyle(
                        fontSize: 11,
                        color: _getStateColor(node.state()),
                      ),
                    ),
                  ],
                ),
              ),
              if (isGroup)
                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: Colors.teal,
                  ),
                  onPressed: () => _toggleNode(node.publicId()),
                ),
            ],
          ),
        ),
//////////////////////////////////////////////////////////
        // Children (recursive)
        if (isGroup && isExpanded) ...[
          const SizedBox(height: 8),
          ...node.children().map((child) =>
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: _buildHierarchyTree(child, level + 1),
              )
          ),
        ],
      ],
    );
  }

  String _getUserNameFromHierarchy(AccountComponent hierarchy) {
    if (hierarchy is AccountGroup) {
      return hierarchy.groupAccount.userName ?? 'User ${hierarchy.groupAccount.userId}';
    }
    return 'Unknown User';
  }

  Color _getStateColor(String state) {
    switch (state) {
      case 'active':
        return Colors.teal;
      case 'frozen':
        return Colors.blue;
      case 'suspended':
        return Colors.orange;
      case 'closed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _exportHierarchy() {
    // دالة لتصدير البيانات
    final exportData = <Map<String, dynamic>>[];

    for (var hierarchy in _hierarchies) {
      exportData.add(_hierarchyToMap(hierarchy));
    }

    Get.snackbar(
      'Export Ready',
      'Hierarchy data prepared for export (${exportData.length} groups)',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.teal,
      colorText: Colors.white,
    );

    print('Hierarchy Data: $exportData');
  }

  Map<String, dynamic> _hierarchyToMap(AccountComponent node) {
    return {
      'type': node.type(),
      'public_id': node.publicId(),
      'state': node.state(),
      'balance': node.totalBalance(),
      'children': node.children().map((child) => _hierarchyToMap(child)).toList(),
    };
  }

  void _showStatistics() {
    double maxBalance = 0;
    String maxBalanceGroup = '';
    int totalLeaves = 0;
    int totalGroups = 0;

    for (var hierarchy in _hierarchies) {
      final balance = double.parse(hierarchy.totalBalance());
      if (balance > maxBalance) {
        maxBalance = balance;
        maxBalanceGroup = _getUserNameFromHierarchy(hierarchy);
      }

      if (hierarchy.children().isNotEmpty) {
        totalGroups++;
      }
      totalLeaves += _countLeafNodes(hierarchy);
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Hierarchy Statistics'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatisticItem('Total Groups', _hierarchies.length.toString()),
              _buildStatisticItem('Total Accounts', totalAccountsCount.toString()),
              _buildStatisticItem(' Total leaves', totalLeaves.toString()),
              _buildStatisticItem('Group Accounts', totalGroups.toString()),
              const Divider(),
              _buildStatisticItem('Total Balance', '\$${totalAllGroupsBalance.toStringAsFixed(2)}'),
              _buildStatisticItem('Max Group Balance', '\$${maxBalance.toStringAsFixed(2)}'),
              Text(
                'Highest Group: $maxBalanceGroup',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Close', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  int _countLeafNodes(AccountComponent node) {
    if (node.children().isEmpty) return 1;

    int count = 0;
    for (var child in node.children()) {
      count += _countLeafNodes(child);
    }
    return count;
  }
}