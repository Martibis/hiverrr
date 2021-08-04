//TODO: think of what can be needed here
class TransactionModel {
  int count;
  String? username;
  String? profilepic;
  DateTime timestamp;
  String textKey;

  TransactionModel(
      {this.username,
      this.profilepic,
      required this.textKey,
      required this.count,
      required this.timestamp});
}
