import 'account_state.dart';

class ClosedState implements AccountState {
  @override
  String get name => 'closed';

  @override
  String get englishName => 'closed';

  @override
  String get colorHex => '#F44336';

  @override
  bool canTransitionTo(String targetState) {
    return false;
  }

  @override
  String transitionError(String targetState) {
    return "الحساب مغلق نهائيًا ولا يمكن تغييره إلى $targetState.";
  }

  @override
  bool get canDeposit => false;

  @override
  bool get canWithdraw => false;

  @override
  bool get canTransfer => false;

  @override
  bool get canModify => false;

  @override
  bool get canClose => false;

  @override
  bool get canDelete => true;

  @override
  bool get canChangeState => false;
}