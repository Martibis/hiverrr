import 'dart:convert';
import 'dart:developer' as d;
import 'dart:math';

import 'package:hiverrr/constants/constants.dart';
import 'package:hiverrr/data/models/user_balance_model.dart';
import 'package:http/http.dart' as http;

class HiveCalls {
  Future<UserBalance> getUserBalance({required String username}) async {
    http.Response r = await http.post(Uri(scheme: 'https', host: HIVENODES[0]),
        body:
            '{"jsonrpc":"2.0", "method":"database_api.find_accounts", "params": {"accounts":["' +
                username +
                '"]}, "id":1}');
    Map data = await jsonDecode(r.body);

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

    http.Response r2 = await http.post(Uri(scheme: 'https', host: HIVENODES[0]),
        body:
            '{"jsonrpc":"2.0", "method":"database_api.get_dynamic_global_properties", "id":1}');
    Map data2 = await jsonDecode(r2.body);

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

    http.Response r3 = await http.post(Uri(scheme: 'https', host: HIVENODES[0]),
        body: '{"jsonrpc":"2.0", "method":"account_history_api.get_account_history", "params":{"account":"' +
            username +
            '", "start":-1, "limit":250, "operation_filter_low": 4503599627370496}, "id": 1}');
    Map data3 = await jsonDecode(r3.body);

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

    http.Response r4 = await http.post(Uri(scheme: 'https', host: HIVENODES[0]),
        body:
            '{"jsonrpc":"2.0", "method":"database_api.get_current_price_feed", "id":1}');
    Map data4 = await jsonDecode(r4.body);

    print(data4);

    num hivePrice = (num.tryParse(data4['result']['base']['amount'])! /
        pow(10, data4['result']['base']['precision']));

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

  //TODO: fix this
  Future<bool> lastTransactions(
      {required String username,
      required String memo,
      required String amount,
      required String nai}) async {
    http.Response r = await http.post(Uri(scheme: 'https', host: HIVENODES[0]),
        body: '{"jsonrpc":"2.0", "method":"account_history_api.get_account_history", "params":{"account":"' +
            username +
            '", "start":-1, "limit":1, "operation_filter_low": 100}, "id": 1}');
    Map data = await jsonDecode(r.body);

    /*    d.log(data['result']['history'].toString()); */
    bool isReceived = false;
    for (int i = 0; i < data['result']['history'].length; i++) {
      d.log(data['result']['history'][i].toString());
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
