class Subscription {
  String username;
  String profilepic;
  num amount;
  String currency;
  num recurrence;
  num remainingExecutions;
  String memo;
  String reccurenceString;

  Subscription(
      {required this.username,
      required this.profilepic,
      required this.amount,
      required this.currency,
      required this.recurrence,
      required this.remainingExecutions,
      required this.memo,
      required this.reccurenceString});
}
