// import '../../domain/repositories/account_repository.dart';
// import '../../domain/dtos/change_state_dto.dart';
// import '../../domain/entities/account_entity.dart';
//
// class ChangeAccountStateUseCase {
//   final AccountRepository repository;
//
//   ChangeAccountStateUseCase(this.repository);
//
//   Future<AccountEntity> execute(String publicId, ChangeStateData data) async {
//     final account = await repository.findByPublicId(publicId);
//
//     if (account == null) {
//       throw Exception('الحساب غير موجود');
//     }
//
//     if (account.isGroup) {
//       throw Exception('لا يمكن تغيير حالة حساب group مباشرة');
//     }
//
//     if (!account.canTransitionTo(data.targetState)) {
//       throw Exception(account.transitionError(data.targetState));
//     }
//
//     return repository.updateStateByPublicId(publicId, data.targetState);
//   }
// }