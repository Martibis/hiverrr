class DelegationModel {
  String? username;
  String? profilepic;
  num amount;
  String currency;
  bool isExpiring;
  DateTime? expireDate;

  DelegationModel(
      {this.username,
      this.profilepic,
      required this.amount,
      required this.currency,
      this.expireDate,
      this.isExpiring = false});
}
