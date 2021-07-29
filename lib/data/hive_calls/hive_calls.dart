import 'dart:async';
import 'dart:convert';
import 'dart:developer' as d;
import 'dart:math';

import 'package:hiverrr/constants/constants.dart';
import 'package:hiverrr/data/models/subscription_model.dart';
import 'package:hiverrr/data/models/user_balance_model.dart';
import 'package:http/http.dart' as http;

class HiveCalls {
  Future<UserBalance> getUserBalance({required String username}) async {
    final results = await Future.wait(([
      http.post(Uri(scheme: 'https', host: HIVENODES[1]),
          body:
              '{"jsonrpc":"2.0", "method":"database_api.find_accounts", "params": {"accounts":["' +
                  username +
                  '"]}, "id":1}'),
      http.post(Uri(scheme: 'https', host: HIVENODES[1]),
          body:
              '{"jsonrpc":"2.0", "method":"database_api.get_dynamic_global_properties", "id":1}'),
      http.post(Uri(scheme: 'https', host: HIVENODES[1]),
          body: '{"jsonrpc":"2.0", "method":"account_history_api.get_account_history", "params":{"account":"' +
              username +
              '", "start":-1, "limit":250, "operation_filter_low": 4503599627370496}, "id": 1}'),
      /*  http.post(Uri(scheme: 'https', host: HIVENODES[1]),
          body:
              '{"jsonrpc":"2.0", "method":"database_api.get_current_price_feed", "id":1}'), */
      http.post(Uri(scheme: 'https', host: HIVENODES[1]),
          body:
              '{"jsonrpc":"2.0", "method":"database_api.get_feed_history", "id":1}')
    ]));
    Map data = await jsonDecode(results[0].body);
    Map data2 = await jsonDecode(results[1].body);
    Map data3 = await jsonDecode(results[2].body);
    /* Map data4 = await jsonDecode(results[3].body); */
    Map data5 = await jsonDecode(results[3].body);

    int? hbdPrecision =
        data['result']['accounts'][0]['hbd_balance']['precision'];
    num? hbdBalance = (num.tryParse(
            data['result']['accounts'][0]['hbd_balance']['amount']))! /
        (pow(10, hbdPrecision!));

    int? savingHbdPrecision =
        data['result']['accounts'][0]['savings_hbd_balance']['precision'];
    num? savingHbdBalance = (num.tryParse(
            data['result']['accounts'][0]['savings_hbd_balance']['amount']))! /
        (pow(10, savingHbdPrecision!));

    int? hivePrecision = data['result']['accounts'][0]['balance']['precision'];
    num? hiveBalance =
        (num.tryParse(data['result']['accounts'][0]['balance']['amount']))! /
            (pow(10, hivePrecision!));

    int? savingHivePrecision =
        data['result']['accounts'][0]['savings_balance']['precision'];
    num? savingHiveBalance = (num.tryParse(
            data['result']['accounts'][0]['savings_balance']['amount']))! /
        (pow(10, savingHivePrecision!));

    int? ownedVestsPrecision =
        data['result']['accounts'][0]['vesting_shares']['precision'];
    num? ownedVestsBalance = (num.tryParse(
            data['result']['accounts'][0]['vesting_shares']['amount']))! /
        (pow(10, ownedVestsPrecision!));

    int? delegatedVestsPrecision =
        data['result']['accounts'][0]['delegated_vesting_shares']['precision'];
    num? delegatedVestsBalance = (num.tryParse(data['result']['accounts'][0]
            ['delegated_vesting_shares']['amount']))! /
        (pow(10, delegatedVestsPrecision!));

    int? receivedVestsPrecision =
        data['result']['accounts'][0]['received_vesting_shares']['precision'];
    num? receivedVestsBalance = (num.tryParse(data['result']['accounts'][0]
            ['received_vesting_shares']['amount']))! /
        (pow(10, receivedVestsPrecision!));

    // print(data2);

    num totalVestingFundHive =
        num.tryParse(data2['result']['total_vesting_fund_hive']['amount']!)! /
            (pow(10, data2['result']['total_vesting_fund_hive']['precision']!));

    num totalVestingShares =
        num.tryParse(data2['result']['total_vesting_shares']['amount']!)! /
            (pow(10, data2['result']['total_vesting_shares']['precision']!));

    num hivePower =
        (totalVestingFundHive * ownedVestsBalance) / totalVestingShares;

    num delegatedHivePower =
        (totalVestingFundHive * delegatedVestsBalance) / totalVestingShares;

    num receivedHivePower =
        (totalVestingFundHive * receivedVestsBalance) / totalVestingShares;

    num hbdSavingsInterestRate = data2['result']['hbd_interest_rate'] / 100;

    num hiveSavingsInterestRate = 0;

    num currentInflationRate =
        (978 - (data2['result']['head_block_number']! / 250000)) / 100;

    num virtualSupply =
        num.tryParse(data2['result']['virtual_supply']['amount']!)! /
            (pow(10, data2['result']['virtual_supply']['precision']!));

    num supplyForInterest = virtualSupply / totalVestingFundHive;

    num vestingRewardPercent =
        (data2['result']['vesting_reward_percent']! / 100 / 100);

    num hivePowerInterestRate =
        currentInflationRate * supplyForInterest * vestingRewardPercent;

    //TODO calcualte curationInterest:

    num headBlockNumber = data2['result']['head_block_number'];
    num limit = 201600; //this is 7 days in 3 second blocks
    num minBlock = headBlockNumber - limit;

    num curationRewards = 0;
    num oldestBlock = headBlockNumber;

    for (int i = 0; i < data3['result']['history'].length; i++) {
      if (data3['result']['history'][i][1]['block'] > minBlock) {
        curationRewards += (num.tryParse(data3['result']['history'][i][1]['op']
                ['value']['reward']['amount'])! /
            pow(
                10,
                data3['result']['history'][i][1]['op']['value']['reward']
                    ['precision']));

        if (data3['result']['history'][i][1]['block'] < oldestBlock) {
          oldestBlock = data3['result']['history'][i][1]['block'];
        }
      }
    }

    num secondsBetweenBlocks = (headBlockNumber - oldestBlock) * 3;

    num secondsInYear = 31536000;

    num times = secondsInYear / secondsBetweenBlocks;

    num curationInterest =
        ((curationRewards / ownedVestsBalance) * times) * 100;

    num hivePrice = (num.tryParse(
            data5['result']['current_max_history']['base']['amount'])! /
        pow(10, data5['result']['current_max_history']['base']['precision']));

    num estimatedUsdValue = hbdBalance +
        (hiveBalance * hivePrice) +
        savingHbdBalance +
        (hivePower * hivePrice) +
        (savingHiveBalance * hivePrice);

    return UserBalance(
        hbdbalance: hbdBalance,
        hivebalance: hiveBalance,
        hbdsavingsbalance: savingHbdBalance,
        hivepoweredupbalance: hivePower,
        hivepowerdelegated: delegatedHivePower,
        hivepowerreceived: receivedHivePower,
        hivesavingsbalance: savingHiveBalance,
        hbdsavinginterestrate: hbdSavingsInterestRate,
        hivesavinginterestrate: hiveSavingsInterestRate,
        hivestakedinterest: hivePowerInterestRate,
        curationinterest: curationInterest,
        estimatedUsdValue: estimatedUsdValue,
        hivePrice: hivePrice);
  }

  //make sure to add redirecturi to params
  Uri getHivesignerSignUrl(
      {required String type, required Map<String, dynamic> params}) {
    Uri uri = Uri(
        scheme: 'https',
        host: 'hivesigner.com',
        path: '/sign/' + type,
        queryParameters: params);

    print(uri);
    return uri;
  }

  Future<List<Subscription>> getSubscriptions(
      {required String username,
      required int pageKey,
      required int limit}) async {
    http.Response r = await http.post(Uri(scheme: 'https', host: HIVENODES[1]),
        body:
            '{"jsonrpc":"2.0", "method":"database_api.find_recurrent_transfers", "params":{"from":"' +
                username +
                '", "start": ' +
                pageKey.toString() +
                ', "limit":' +
                limit.toString() +
                '}, "id": 1}');
    Map data = await jsonDecode(r.body);

    print(data);

    List<Subscription> subscriptions = [];

    for (int i = 0; i < data['result']['recurrent_transfers'].length; i++) {
      Map subscriptionMap = data['result']['recurrent_transfers'][0];

      print(subscriptionMap);
      String username = subscriptionMap['to'];
      String profilepic = 'https://images.ecency.com/webp/u/' +
          subscriptionMap['to'] +
          '/avatar/medium';

      num amount = (num.tryParse(subscriptionMap['amount']['amount'])! /
          pow(10, subscriptionMap['amount']['precision']));

      String currency =
          subscriptionMap['amount']['nai'] == HIVENAI ? 'HIVE' : 'HBD';
      String memo = subscriptionMap['memo'];
      num recurrence = subscriptionMap['recurrence'];
      String recurrenceString =
          'every ' + recurrence.toStringAsFixed(0) + ' hours';
      switch (recurrence) {
        case 24:
          recurrenceString = 'Daily';
          break;
        case 168:
          recurrenceString = 'Weekly';
          break;
        case 730:
          recurrenceString = 'Monthly';
          break;
        case 8760:
          recurrenceString = 'Yearly';
      }
      num remainingExecutions = subscriptionMap['remaining_executions'];

      Subscription subscription = Subscription(
          username: username,
          profilepic: profilepic,
          amount: amount,
          currency: currency,
          memo: memo,
          recurrence: recurrence,
          remainingExecutions: remainingExecutions,
          reccurenceString: recurrenceString);

      subscriptions.add(subscription);
    }

    return subscriptions;
  }

  //TODO: check why this is so slow
  Future<bool> receivedTransaction(
      {required String username,
      required String memo,
      required String amount,
      required String nai}) async {
    http.Response r = await http.post(Uri(scheme: 'https', host: HIVENODES[1]),
        body: '{"jsonrpc":"2.0", "method":"account_history_api.get_account_history", "params":{"account":"' +
            username +
            '", "start":-1, "limit":1, "operation_filter_low": 100}, "id": 1}');
    Map data = await jsonDecode(r.body);

    bool isReceived = false;
    for (int i = 0; i < data['result']['history'].length; i++) {
      Map tx = data['result']['history'][i][1]['op'];

      String txUsername = tx['value']['to'];
      String txAmount = tx['value']['amount']['amount'];
      num txPrecision = tx['value']['amount']['precision'];
      String txNai = tx['value']['amount']['nai'];
      String txMemo = tx['value']['memo'];

      print("TX");
      print(txUsername);
      print(txAmount);
      print(txPrecision);
      print(txNai);
      print(txMemo);

      print('PASSED');
      print(username);
      print(amount);
      print(memo);
      print(nai);

      if (txUsername == username &&
          (num.parse(txAmount) / (pow(10, txPrecision))) == num.parse(amount) &&
          txNai == nai &&
          txMemo == memo) {
        isReceived = true;
      }
    }
    print(isReceived);
    return isReceived;
  }
}
