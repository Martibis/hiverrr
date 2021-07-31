import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiverrr/blocs/authbloc/auth_bloc.dart';
import 'package:hiverrr/blocs/userbalance_bloc.dart/userbalance_bloc.dart';
import 'package:hiverrr/constants/constants.dart';
import 'package:hiverrr/data/models/user_balance_model.dart';
import 'package:hiverrr/presentation/staking/power_down.dart';
import 'package:hiverrr/presentation/staking/power_up.dart';
import 'package:hiverrr/presentation/widgets/neumorphism/neumorphism_container.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:webview_flutter/webview_flutter.dart';

class StakingInfo extends StatelessWidget {
  final UserBalance userBalance;
  const StakingInfo({Key? key, required this.userBalance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeumorphismContainer(
      tapable: true,
      padding: EdgeInsets.fromLTRB(20, 15, 20, 25),
      color: Theme.of(context).backgroundColor,
      expandable: true,
      onTap: () {},
      expandableContent: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(
                height: 50,
              ),
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                  text: 'HIVE interest (APR):   ',
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                TextSpan(
                  text: userBalance.hivestakedinterest.toStringAsFixed(2) + '%',
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      color: Theme.of(context).highlightColor,
                      fontWeight: FontWeight.bold),
                ),
              ])),
              Container(
                height: 15,
              ),
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                  text: 'Curation (APR):   ',
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                TextSpan(
                  text: userBalance.curationinterest.toStringAsFixed(2) + '%',
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      color: Theme.of(context).highlightColor,
                      fontWeight: FontWeight.bold),
                ),
              ])),
              Container(
                height: 15,
              ),
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                  text: 'Delegated Hive:   ',
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                TextSpan(
                  text: userBalance.hivepowerdelegated.toStringAsFixed(3),
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ])),
              Container(
                height: 15,
              ),
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                  text: 'Received Hive:   ',
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                TextSpan(
                  text: userBalance.hivepowerreceived.toStringAsFixed(3),
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ])),
              Container(
                height: 15,
              ),
              userBalance.powerDownRate > 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                            text: 'Powering down HIVE:   ',
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                          TextSpan(
                            text: userBalance.powerDownRate.toStringAsFixed(3),
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: ' (' +
                                timeago.format(userBalance.nextPowerDown,
                                    allowFromNow: true) +
                                ')',
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ])),
                        Container(
                          height: 15,
                        )
                      ],
                    )
                  : Container(),
              Divider(
                height: 25,
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(
                          builder: (_) => PowerUp(
                                maxHive: userBalance.hivebalance.toString(),
                              )));
                },
                child: Container(
                  padding: EdgeInsets.only(top: 15),
                  child: Text(
                    'Power up',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              userBalance.powerDownRate > 0
                  ? GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        confirmTransaction(String url) {
                          WebViewController? webViewController;
                          if (Platform.isAndroid)
                            WebView.platform = SurfaceAndroidWebView();
                          BotToast.showAnimationWidget(
                              clickClose: false,
                              allowClick: false,
                              onlyOne: true,
                              crossPage: true,
                              enableKeyboardSafeArea: true,
                              backButtonBehavior: BackButtonBehavior.close,
                              wrapToastAnimation: (controller, cancel, child) =>
                                  Stack(
                                    children: <Widget>[
                                      GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          cancel();
                                        },
                                        //The DecoratedBox here is very important,he will fill the entire parent component
                                        child: AnimatedBuilder(
                                          builder: (_, child) => Opacity(
                                            opacity: controller.value,
                                            child: child,
                                          ),
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                                color: myColors.black90),
                                            child: SizedBox.expand(),
                                          ),
                                          animation: controller,
                                        ),
                                      ),
                                      BlocBuilder<AuthBloc, AuthState>(
                                        builder: (_, state) {
                                          if (state is LoggedIn)
                                            return SafeArea(
                                              child: Container(
                                                padding:
                                                    EdgeInsets.only(top: 50),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10),
                                                          topRight:
                                                              Radius.circular(
                                                                  10)),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10))),
                                                    child: WebView(
                                                      javascriptMode:
                                                          JavascriptMode
                                                              .unrestricted,
                                                      initialUrl:
                                                          url.toString(),
                                                      onPageStarted: (url) {
                                                        Uri uri =
                                                            Uri.parse(url);

                                                        //this means succesful transfer
                                                        if (uri.host.contains(
                                                            'hiverrr')) {
                                                          BotToast.showText(
                                                            crossPage: true,
                                                            text:
                                                                "Stopping power down was succesful! 🤩",
                                                            textStyle: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                          );
                                                          BlocProvider.of<
                                                                      UserbalanceBloc>(
                                                                  context)
                                                              .add(GetUserBalance(
                                                                  username: state
                                                                      .user
                                                                      .username));
                                                          cancel();
                                                        }
                                                      },
                                                      onWebViewCreated:
                                                          (controller) {
                                                        webViewController =
                                                            controller;
                                                      },
                                                      onProgress:
                                                          (progress) async {
                                                        String? url =
                                                            await webViewController!
                                                                .currentUrl();
                                                        if (url ==
                                                                'https://hivesigner.com/' ||
                                                            url ==
                                                                'https://hivesigner.com') {
                                                          cancel();
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          return Container();
                                        },
                                      )
                                    ],
                                  ),
                              toastBuilder: (cancelFunc) => AlertDialog(),
                              animationDuration: Duration(milliseconds: 0));
                        }

                        Map<String, dynamic> op = {
                          "account": '__signer',
                          "vesting_shares": 0.toString() + ' VESTS',
                          "redirect_uri": 'https://hiverrr.com'
                        };
                        Uri uri = hc.getHivesignerSignUrl(
                            type: 'withdraw_vesting', params: op);
                        confirmTransaction(uri.toString());
                      },
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Text(
                          'Stop power down',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  : GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.of(context, rootNavigator: true)
                            .push(MaterialPageRoute(
                                builder: (_) => PowerDown(
                                      hpToVestsMultiplier:
                                          userBalance.hpToVestsMultiplier,
                                      maxHive: (userBalance
                                                  .hivepoweredupbalance -
                                              userBalance.hivepowerdelegated -
                                              userBalance.hivepowerreceived)
                                          .toString(),
                                    )));
                      },
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Text(
                          'Power down',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  print('TODO');
                },
                child: Container(
                  padding: EdgeInsets.only(top: 15),
                  child: Text(
                    'Manage delegations',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          )),
      mainContent: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Staking account',
            ),
            Container(
              height: 25,
            ),
            RichText(
                text: TextSpan(children: [
              TextSpan(
                text: 'HIVE:   ',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(fontSize: 18),
              ),
              TextSpan(
                text: userBalance.hivepoweredupbalance.toStringAsFixed(3),
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ])),
          ],
        ),
      ),
    );
  }
}
