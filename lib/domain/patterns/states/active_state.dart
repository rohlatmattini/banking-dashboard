import 'account_state.dart';

class ActiveState implements AccountState {
  @override
  String get name => 'active';

  @override
  String get englishName => 'Active';

  @override
  String get colorHex => '#4CAF50';

  @override
  bool canTransitionTo(String targetState) {
    return ['frozen', 'suspended', 'closed'].contains(targetState);
  }

  @override
  String transitionError(String targetState) {
    return "Cannot transition from active to $targetState.";
  }

  @override
  bool get canDeposit => true;

  @override
  bool get canWithdraw => true;

  @override
  bool get canTransfer => true;

  @override
  bool get canModify => true;

  @override
  bool get canClose => true;

  @override
  bool get canDelete => false;

  @override
  bool get canChangeState => true;
}