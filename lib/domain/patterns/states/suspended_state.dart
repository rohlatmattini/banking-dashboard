import 'account_state.dart';

class SuspendedState implements AccountState {
  @override
  String get name => 'suspended';

  @override
  String get englishName => 'suspended';

  @override
  String get colorHex => '#FF9800';

  @override
  bool canTransitionTo(String targetState) {
    return ['active', 'closed'].contains(targetState);
  }

  @override
  String transitionError(String targetState) {
    return "لا يمكن الانتقال من suspended إلى $targetState.";
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