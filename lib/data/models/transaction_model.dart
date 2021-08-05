class TransactionModel {
  DateTime timestamp;
  int count;
  String textKey;
  String asset;
  bool isProfilepic;
  String infoText;
  String amountText;
  String? secondInfoText;
  bool hasSecondInfoText;
  bool showTransaction;
  String emoji;

  TransactionModel(
      {required this.textKey,
      required this.count,
      required this.timestamp,
      required this.amountText,
      required this.asset,
      required this.infoText,
      required this.isProfilepic,
      this.secondInfoText,
      this.hasSecondInfoText = false,
      this.showTransaction = true,
      required this.emoji});
}
