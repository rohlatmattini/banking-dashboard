abstract class AccountState {
  String get name; // 'active', 'frozen', etc.
  String get colorHex;
  String get englishName;

  bool canTransitionTo(String targetState);
  String transitionError(String targetState);

  bool get canDeposit;
  bool get canWithdraw;
  bool get canTransfer;
  bool get canModify;
  bool get canClose;
  bool get canDelete;
  bool get canChangeState;

}