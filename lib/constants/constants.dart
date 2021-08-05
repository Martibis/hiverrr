import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hiverrr/constants/bottoasts.dart';
import 'package:hiverrr/constants/ui_classes.dart';
import 'package:hiverrr/data/hive_calls/hive_calls.dart';

const FlutterSecureStorage STORAGE = FlutterSecureStorage();

const List HIVENODES = [
  'api.hive.blog',
  'api.openhive.network',
  'anyx.io',
  'api.hivekings.com',
  'rpc.ausbit.dev',
  'rpc.ecency.com'
];

const String HBDNAI = '@@000000013';
const String HIVENAI = '@@000000021';
const String VESTSNAI = '@@000000037';

const num HOURSPERDAY = 24;
const num HOURSPERWEEK = 168;
const num HOURSPERMONTH = 730;
const num HOURSPERYEAR = 8760;

final HiveCalls hc = HiveCalls();

String currencyFromNai(String nai) {
  String currency;
  switch (nai) {
    case HIVENAI:
      {
        currency = 'HIVE';
      }
      break;
    case VESTSNAI:
      {
        currency = 'VESTS';
      }
      break;
    case HBDNAI:
      {
        currency = 'HBD';
      }
      break;
    default:
      {
        currency = 'HIVE';
      }
  }
  return currency;
}

const transferTypes = [
  'curation_reward',
  'author_reward',
  'comment_benefactor_reward',
  'claim_reward_balance',
  'transfer',
  'transfer_to_savings',
  'transfer_from_savings',
  'transfer_to_vesting',
  'withdraw_vesting',
  'fill_order',
  'escrow_transfer',
  'escrow_dispute',
  'escrow_release',
  'escrow_approve',
  'delegate_vesting_shares',
  'cancel_transfer_from_savings',
  'fill_convert_request',
  'fill_transfer_from_savings',
  'fill_vesting_withdraw',
  'recurrent_transfer'
];

final myColors = MyColors();
final themeDatas = ThemeDatas();
final myEdgeInsets = MyEdgeInsets();
final botToasts = BotToasts();
final myBoxShadows = MyBoxShadows();
