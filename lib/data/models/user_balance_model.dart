class UserBalance {
  num hbdbalance;
  num hivebalance;
  num hbdsavingsbalance;
  num hivesavingsbalance;
  num hivepoweredupbalance;
  num hivepowerdelegated;
  num hivepowerreceived;
  num hbdsavinginterestrate;
  num hivesavinginterestrate;
  num hivestakedinterest;
  num curationinterest;
  num estimatedUsdValue;
  num hivePrice;

  UserBalance(
      {required this.hbdbalance,
      required this.hivebalance,
      required this.hbdsavingsbalance,
      required this.hivepoweredupbalance,
      required this.hivepowerdelegated,
      required this.hivepowerreceived,
      required this.hivesavingsbalance,
      required this.hbdsavinginterestrate,
      required this.hivesavinginterestrate,
      required this.curationinterest,
      required this.hivestakedinterest,
      required this.estimatedUsdValue,
      required this.hivePrice});
}
