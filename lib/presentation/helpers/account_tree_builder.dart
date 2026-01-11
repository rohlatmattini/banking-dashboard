// // lib/domain/helpers/account_tree_builder.dart
//
//
// import '../../domain/entities/account_entity.dart';
// import '../../domain/enums/account_type_enum.dart';
// import '../../domain/patterns/composite/account_group.dart';
// import '../../domain/patterns/composite/account_leaf.dart';
// import '../../domain/patterns/states/account_state_factory.dart';
//
// class AccountTreeBuilder {
//   AccountGroup buildForUser(List<AccountEntity> accounts) {
//     final groupEntity = findGroupEntity(accounts);
//     final group = AccountGroup(groupEntity);
//
//     for (var account in accounts) {
//       if (account.type == AccountTypeEnum.GROUP) continue;
//       if (account.parentId == groupEntity.id) {
//         group.add(AccountLeaf(account));
//       }
//     }
//
//     return group;
//   }
//
//   AccountEntity findGroupEntity(List<AccountEntity> accounts) {
//     for (var account in accounts) {
//       if (account.type == AccountTypeEnum.GROUP) {
//         return account;
//       }
//     }
//
//     return AccountEntity(
//       id: 0,
//       publicId: 'virtual_group_${DateTime.now().millisecondsSinceEpoch}',
//       userId: accounts.isNotEmpty ? accounts.first.userId : 0,
//       parentId: null,
//       type: AccountTypeEnum.GROUP,
//       balance: 0.0,
//       state: AccountStateFactory.from('active'),
//       dailyLimit: null,
//       monthlyLimit: null,
//       closedAt: null,
//       createdAt: DateTime.now(),
//       updatedAt: DateTime.now(),
//       userName: accounts.isNotEmpty ? accounts.first.userName : 'Virtual Group',
//       userEmail: accounts.isNotEmpty ? accounts.first.userEmail : null,
//       userPhone: accounts.isNotEmpty ? accounts.first.userPhone : null,
//     );
//   }
// }