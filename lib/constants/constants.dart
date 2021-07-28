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

final HiveCalls hc = HiveCalls();

final myColors = MyColors();
final themeDatas = ThemeDatas();
final myEdgeInsets = MyEdgeInsets();
final botToasts = BotToasts();
final myBoxShadows = MyBoxShadows();
