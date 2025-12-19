import 'account_state.dart';

class FrozenState implements AccountState {
  @override
  String get name => 'frozen';

  @override
  String get englishName => 'frozen';

  @override
  String get colorHex => '#2196F3';

  @override
  bool canTransitionTo(String targetState) {
    return ['active', 'suspended', 'closed'].contains(targetState);
  }

  @override
  String transitionError(String targetState) {
    return "لا يمكن الانتقال من frozen إلى $targetState.";
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
  bool get canClose => true;

  @override
  bool get canDelete => false;

  @override
  bool get canChangeState => true;
}