// lib/domain/helpers/account_tree_builder.dart
import '../entities/account_entity.dart';
import '../patterns/composite/account_component.dart';
import '../patterns/composite/account_group.dart';
import '../patterns/composite/account_leaf.dart';
import '../enums/account_type_enum.dart';
import '../patterns/states/account_state_factory.dart';

class AccountTreeBuilder {

  AccountGroup buildForUser(List<AccountEntity> accounts) {
    print('🔨 Building hierarchy for ${accounts.length} accounts'); // ✅ ديبق

    if (accounts.isEmpty) {
      print('⚠️ No accounts to build hierarchy');
      return _createEmptyGroup();
    }

    AccountEntity groupEntity;
    try {
      groupEntity = _findOrCreateGroupEntity(accounts);
      print('🔨 Group found/created: ${groupEntity.publicId}'); // ✅ ديبق
    } catch (e) {
      print('❌ Error finding group: $e');
      groupEntity = _createDefaultGroup(accounts.first);
    }

    final group = AccountGroup(groupEntity);
    print('🔨 Group created with account: ${groupEntity.publicId}'); // ✅ ديبق

    int addedCount = 0;
    for (var account in accounts) {
      if (account.id == groupEntity.id ||
          account.publicId == groupEntity.publicId) {
        continue;
      }


      if (account.parentId == null || account.parentId == groupEntity.id) {
        group.add(AccountLeaf(account));
        addedCount++;
        print('➕ Added account: ${account.publicId} (${account.type.value})'); // ✅ ديبق
      } else {
        print('➖ Skipped account: ${account.publicId} (parent: ${account.parentId})'); // ✅ ديبق
      }
    }

    print('✅ Total accounts added to group: $addedCount'); // ✅ ديبق
    print('✅ Group now has ${group.children().length} children'); // ✅ ديبق

    return group;
  }

  AccountEntity _findOrCreateGroupEntity(List<AccountEntity> accounts) {
    // 1. البحث عن Group Account موجود
    for (var account in accounts) {
      if (account.type == AccountTypeEnum.GROUP) {
        print('🔍 Found existing group: ${account.publicId}'); // ✅ ديبق
        return account;
      }
    }

    // 2. إذا لم يوجد، البحث عن أي حساب يمكن أن يكون Group
    if (accounts.isNotEmpty) {
      print('🔍 No group found, using first account as virtual group'); // ✅ ديبق
      return accounts.first;
    }

    // 3. إذا لم يوجد أي حسابات، إنشاء Group وهمي
    print('🔍 Creating virtual group'); // ✅ ديبق
    return _createVirtualGroup();
  }

  AccountEntity _createDefaultGroup(AccountEntity firstAccount) {
    return AccountEntity(
      id: -1,
      publicId: 'group_${firstAccount.userId}',
      userId: firstAccount.userId,
      parentId: null,
      type: AccountTypeEnum.GROUP,
      balance: 0.0,
      state: AccountStateFactory.from('active'),
      dailyLimit: null,
      monthlyLimit: null,
      closedAt: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userName: firstAccount.userName ?? 'Default Group',
      userEmail: firstAccount.userEmail,
      userPhone: firstAccount.userPhone,
    );
  }

  AccountEntity _createVirtualGroup() {
    return AccountEntity(
      id: -1,
      publicId: 'virtual_group_${DateTime.now().millisecondsSinceEpoch}',
      userId: 0,
      parentId: null,
      type: AccountTypeEnum.GROUP,
      balance: 0.0,
      state: AccountStateFactory.from('active'),
      dailyLimit: null,
      monthlyLimit: null,
      closedAt: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userName: 'Virtual Group',
      userEmail: null,
      userPhone: null,
    );
  }

  AccountGroup _createEmptyGroup() {
    final virtualGroup = _createVirtualGroup();
    return AccountGroup(virtualGroup);
  }
}