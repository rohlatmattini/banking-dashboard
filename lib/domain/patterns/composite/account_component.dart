abstract class AccountComponent {
  String publicId();
  String type();
  String state();
  String balance();
  String totalBalance();
  List<AccountComponent> children();
}