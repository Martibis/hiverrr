import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiverrr/blocs/authbloc/auth_bloc.dart';
import 'package:hiverrr/blocs/subscriptions_bloc/subscriptions_bloc.dart';
import 'package:hiverrr/blocs/userbalance_bloc.dart/userbalance_bloc.dart';
import 'package:hiverrr/constants/constants.dart';
import 'package:hiverrr/data/models/subscription_model.dart';
import 'package:hiverrr/presentation/widgets/auth/ask_login.dart';
import 'package:hiverrr/presentation/widgets/neumorphism/neumorphism_container.dart';
import 'package:hiverrr/presentation/widgets/screen_header/screen_header.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Subscription extends StatefulWidget {
  final SubscriptionModel? subscription;
  final bool changingSubscription;
  Subscription({Key? key, this.subscription, this.changingSubscription = false})
      : super(key: key);

  @override
  _SubscriptionState createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  bool isHive = false;
  num recurrence = HOURSPERMONTH;
  GlobalKey<FormState> _subscriptionFormKey = GlobalKey<FormState>();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _memoController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  WebViewController? webViewController;

  confirmTransaction({required String url, bool isCancel = false}) {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    BotToast.showAnimationWidget(
        clickClose: false,
        allowClick: false,
        onlyOne: true,
        crossPage: true,
        enableKeyboardSafeArea: true,
        backButtonBehavior: BackButtonBehavior.close,
        wrapToastAnimation: (controller, cancel, child) => Stack(
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
                      decoration: BoxDecoration(color: myColors.black90),
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
                          padding: EdgeInsets.only(top: 50),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10)),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10))),
                              child: WebView(
                                javascriptMode: JavascriptMode.unrestricted,
                                initialUrl: url.toString(),
                                onPageStarted: (url) {
                                  Uri uri = Uri.parse(url);
                                  //this means succesful transfer
                                  if (uri.host.contains('hiverrr')) {
                                    BotToast.showText(
                                      crossPage: true,
                                      text: widget.changingSubscription
                                          ? (isCancel
                                              ? "Subscription canceled"
                                              : "Succesfully updated! 🤩")
                                          : "Succesfully subscribed! 🤩",
                                      textStyle: TextStyle(color: Colors.white),
                                      borderRadius: BorderRadius.circular(4),
                                    );
                                    BlocProvider.of<UserbalanceBloc>(context)
                                        .add(GetUserBalance(
                                            username: state.user.username));
                                    BlocProvider.of<SubscriptionsBloc>(context)
                                        .add(FetchSubscriptions(
                                            pageKey: 0,
                                            username: state.user.username));
                                    cancel();
                                    Navigator.of(context).pop();
                                  }
                                },
                                onWebViewCreated: (controller) {
                                  webViewController = controller;
                                },
                                onProgress: (progress) async {
                                  String? url =
                                      await webViewController!.currentUrl();
                                  if (url == 'https://hivesigner.com/' ||
                                      url == 'https://hivesigner.com') {
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

  bool _validInputs() {
    if (_subscriptionFormKey.currentState!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  String? validateUsername(String? t) {
    String value = t!.replaceAll('@', '');
    var i, label, length, ref;

    length = value.length;
    if (length == 0) {
      return 'Can not be empty';
    }
    if (length < 3) {
      return 'Username is too short';
    }
    if (length > 16) {
      return 'Username is too long';
    }

    ref = value.split('.');
    for (i = 0; i < ref.length; i++) {
      label = ref[i];

      if (!(label.length >= 3)) {
        return 'Not a valid username';
      }
    }
    return null;
  }

  String? validateNotEmpty(String? value) {
    if (value!.trim().length == 0) {
      return 'Can not be empty';
    } else {
      return null;
    }
  }

  @override
  void initState() {
    if (widget.subscription != null) {
      _usernameController.text = widget.subscription!.username;
      _amountController.text = widget.subscription!.amount.toString();
      _memoController.text = widget.subscription!.memo;
      isHive = widget.subscription!.currency == 'HIVE' ? true : false;
      recurrence = widget.subscription!.recurrence;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => BlocProvider.of<AuthBloc>(context))
      ],
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is LoggedIn) {
                return Form(
                  key: _subscriptionFormKey,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          physics: BouncingScrollPhysics(),
                          children: [
                            ScreenHeader(
                                title: widget.changingSubscription
                                    ? 'Update subscription'
                                    : 'New subscription',
                                hasBackButton: true),
                            Row(
                              children: [
                                Container(
                                  width: 25,
                                ),
                                Expanded(
                                  child: NeumorphismContainer(
                                    margin: EdgeInsets.all(0),
                                    padding:
                                        EdgeInsets.fromLTRB(20, 20, 20, 20),
                                    color: isHive
                                        ? Theme.of(context).accentColor
                                        : Theme.of(context).backgroundColor,
                                    onTap: () {
                                      setState(() {
                                        if (!isHive) {
                                          isHive = !isHive;
                                        }
                                      });
                                    },
                                    mainContent: Text(
                                      'hive',
                                      style: TextStyle(
                                          color: isHive
                                              ? Colors.white
                                              : Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .color,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    expandableContent: Container(),
                                    expandable: false,
                                  ),
                                ),
                                Container(
                                  width: 25,
                                ),
                                Expanded(
                                  child: NeumorphismContainer(
                                    margin: EdgeInsets.all(0),
                                    padding:
                                        EdgeInsets.fromLTRB(20, 20, 20, 20),
                                    color: !isHive
                                        ? Theme.of(context).accentColor
                                        : Theme.of(context).backgroundColor,
                                    onTap: () {
                                      setState(() {
                                        if (isHive) {
                                          isHive = !isHive;
                                        }
                                      });
                                    },
                                    mainContent: Text(
                                      'hbd',
                                      style: TextStyle(
                                          color: !isHive
                                              ? Colors.white
                                              : Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .color,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    expandableContent: Container(),
                                    expandable: false,
                                  ),
                                ),
                                Container(
                                  width: 25,
                                ),
                              ],
                            ),
                            Container(
                              height: 25,
                            ),
                            Container(
                              padding: myEdgeInsets.leftRight,
                              child: TextFormField(
                                controller: _usernameController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: validateUsername,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: '@username',
                                ),
                                //textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              height: 25,
                            ),
                            Container(
                              padding: myEdgeInsets.leftRight,
                              child: TextFormField(
                                controller: _amountController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: validateNotEmpty,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r"[0-9.]")),
                                  TextInputFormatter.withFunction(
                                      (oldValue, newValue) {
                                    try {
                                      final text = newValue.text;
                                      if (text.isNotEmpty) double.parse(text);
                                      return newValue;
                                    } catch (e) {
                                      //TODO
                                    }
                                    return oldValue;
                                  }),
                                ],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '10.00',
                                ),
                                //textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              height: 25,
                            ),
                            Container(
                              padding: myEdgeInsets.leftRight,
                              child: TextFormField(
                                controller: _memoController,
                                minLines: 6,
                                maxLines: 6,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'memo',
                                ),
                                //textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              height: 25,
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 25,
                                ),
                                Expanded(
                                  child: NeumorphismContainer(
                                    margin: EdgeInsets.all(0),
                                    padding: EdgeInsets.fromLTRB(5, 20, 5, 20),
                                    color: recurrence == HOURSPERDAY
                                        ? Theme.of(context).accentColor
                                        : Theme.of(context).backgroundColor,
                                    onTap: () {
                                      setState(() {
                                        recurrence = HOURSPERDAY;
                                      });
                                    },
                                    mainContent: Text(
                                      'daily',
                                      style: TextStyle(
                                          color: recurrence == HOURSPERDAY
                                              ? Colors.white
                                              : Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .color,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    expandableContent: Container(),
                                    expandable: false,
                                  ),
                                ),
                                Container(
                                  width: 25,
                                ),
                                Expanded(
                                  child: NeumorphismContainer(
                                    margin: EdgeInsets.all(0),
                                    padding: EdgeInsets.fromLTRB(5, 20, 5, 20),
                                    color: recurrence == HOURSPERWEEK
                                        ? Theme.of(context).accentColor
                                        : Theme.of(context).backgroundColor,
                                    onTap: () {
                                      setState(() {
                                        recurrence = HOURSPERWEEK;
                                      });
                                    },
                                    mainContent: Text(
                                      'weekly',
                                      style: TextStyle(
                                          color: recurrence == HOURSPERWEEK
                                              ? Colors.white
                                              : Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .color,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    expandableContent: Container(),
                                    expandable: false,
                                  ),
                                ),
                                Container(
                                  width: 25,
                                ),
                                Expanded(
                                  child: NeumorphismContainer(
                                    margin: EdgeInsets.all(0),
                                    padding: EdgeInsets.fromLTRB(5, 20, 5, 20),
                                    color: recurrence == HOURSPERMONTH
                                        ? Theme.of(context).accentColor
                                        : Theme.of(context).backgroundColor,
                                    onTap: () {
                                      setState(() {
                                        recurrence = HOURSPERMONTH;
                                      });
                                    },
                                    mainContent: Text(
                                      'monthly',
                                      style: TextStyle(
                                          color: recurrence == HOURSPERMONTH
                                              ? Colors.white
                                              : Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .color,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    expandableContent: Container(),
                                    expandable: false,
                                  ),
                                ),
                                Container(
                                  width: 25,
                                ),
                                Expanded(
                                  child: NeumorphismContainer(
                                    margin: EdgeInsets.all(0),
                                    padding: EdgeInsets.fromLTRB(5, 20, 5, 20),
                                    color: recurrence == HOURSPERYEAR
                                        ? Theme.of(context).accentColor
                                        : Theme.of(context).backgroundColor,
                                    onTap: () {
                                      setState(() {
                                        recurrence = HOURSPERYEAR;
                                      });
                                    },
                                    mainContent: Text(
                                      'yearly',
                                      style: TextStyle(
                                          color: recurrence == HOURSPERYEAR
                                              ? Colors.white
                                              : Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .color,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    expandableContent: Container(),
                                    expandable: false,
                                  ),
                                ),
                                Container(
                                  width: 25,
                                ),
                              ],
                            ),
                            Container(
                              height: 25,
                            ),
                          ],
                        ),
                      ),
                      Row(children: [
                        Container(
                          width: 25,
                        ),
                        widget.changingSubscription
                            ? Expanded(
                                child: NeumorphismContainer(
                                  margin: EdgeInsets.all(0),
                                  color: Theme.of(context).backgroundColor,
                                  tapable: true,
                                  onTap: () {
                                    if (_validInputs()) {
                                      Map<String, dynamic> op = {
                                        "from": '__signer',
                                        "to": _usernameController.text
                                            .replaceAll('@', ''),
                                        "amount": 0.00.toString() +
                                            (isHive ? ' HIVE' : ' HBD'),
                                        "memo": '',
                                        "recurrence": 24.toString(),
                                        "executions": 2.toString(),
                                        "redirect_uri": 'https://hiverrr.com'
                                      };

                                      Uri uri = hc.getHivesignerSignUrl(
                                          type: 'recurrent_transfer',
                                          params: op);

                                      if (FocusScope.of(context).isFirstFocus) {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                      }
                                      confirmTransaction(
                                          url: uri.toString(), isCancel: true);
                                    }
                                  },
                                  mainContent: Center(
                                    child: Text(
                                      'Cancel',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText2!
                                            .color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  expandableContent: Container(),
                                  expandable: false,
                                ),
                              )
                            : Container(),
                        widget.changingSubscription
                            ? Container(
                                width: 25,
                              )
                            : Container(),
                        Expanded(
                          child: NeumorphismContainer(
                            margin: EdgeInsets.all(0),
                            color: Theme.of(context).accentColor,
                            tapable: true,
                            onTap: () {
                              if (_validInputs()) {
                                Map<String, dynamic> op = {
                                  "from": '__signer',
                                  "to": _usernameController.text
                                      .replaceAll('@', ''),
                                  "amount": _amountController.text +
                                      (isHive ? ' HIVE' : ' HBD'),
                                  "memo": _memoController.text,
                                  "recurrence": recurrence.toString(),
                                  "executions":
                                      (((HOURSPERYEAR * 2) / recurrence)
                                                  .floor() -
                                              1)
                                          .toString(),
                                  "redirect_uri": 'https://hiverrr.com'
                                };

                                Uri uri = hc.getHivesignerSignUrl(
                                    type: 'recurrent_transfer', params: op);

                                if (FocusScope.of(context).isFirstFocus) {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                }
                                confirmTransaction(url: uri.toString());
                              }
                            },
                            mainContent: Center(
                              child: Text(
                                'Continue',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            expandableContent: Container(),
                            expandable: false,
                          ),
                        ),
                        Container(
                          width: 25,
                        ),
                      ]),
                      Container(
                        height: 10,
                      ),
                      Container(
                        padding: myEdgeInsets.leftRight,
                        child: Text(
                          'Subscriptions are active for 2 years or until canceled.',
                          style: TextStyle(fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        height: 25,
                      ),
                    ],
                  ),
                );
              }
              if (state is Loading) {
                return Text('Loading');
              }
              return AskLogin();
            },
          ),
        ),
      ),
    );
  }
}
