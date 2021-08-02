import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiverrr/blocs/authbloc/auth_bloc.dart';
import 'package:hiverrr/blocs/delegations_bloc/delegations_bloc.dart';
import 'package:hiverrr/blocs/subscriptions_bloc/subscriptions_bloc.dart';
import 'package:hiverrr/blocs/userbalance_bloc.dart/userbalance_bloc.dart';
import 'package:hiverrr/constants/constants.dart';
import 'package:hiverrr/data/models/delegation_model.dart';
import 'package:hiverrr/presentation/widgets/auth/ask_login.dart';
import 'package:hiverrr/presentation/widgets/neumorphism/neumorphism_container.dart';
import 'package:hiverrr/presentation/widgets/screen_header/screen_header.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Delegation extends StatefulWidget {
  final DelegationModel? delegation;
  final bool changingDelegation;
  final num vestsToHive;
  Delegation(
      {Key? key,
      this.delegation,
      this.changingDelegation = false,
      required this.vestsToHive})
      : super(key: key);

  @override
  _DelegationState createState() => _DelegationState();
}

class _DelegationState extends State<Delegation> {
  GlobalKey<FormState> _subscriptionFormKey = GlobalKey<FormState>();
  TextEditingController _amountController = TextEditingController();
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
                                      text: widget.changingDelegation
                                          ? (isCancel
                                              ? "Delegating canceled"
                                              : "Succesfully updated! 🤩")
                                          : "Succesfully delegated! 🤩",
                                      textStyle: TextStyle(color: Colors.white),
                                      borderRadius: BorderRadius.circular(4),
                                    );
                                    BlocProvider.of<UserbalanceBloc>(context)
                                        .add(GetUserBalance(
                                            username: state.user.username));
                                    BlocProvider.of<DelegationsBloc>(context)
                                        .add(FetchDelegations(
                                            vestsToHive: widget.vestsToHive,
                                            pageKey: 0,
                                            isRefresh: true,
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
    if (widget.delegation != null) {
      _usernameController.text = widget.delegation!.username!;
      _amountController.text = widget.delegation!.amount.toStringAsFixed(3);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                              title: widget.changingDelegation
                                  ? 'Update delegation'
                                  : 'New delegation',
                              hasBackButton: true),
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
                                  helperText: 'Amount of HIVE to delegate'),
                              //textAlign: TextAlign.center,
                            ),
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
                      widget.changingDelegation
                          ? Expanded(
                              child: NeumorphismContainer(
                                margin: EdgeInsets.all(0),
                                color: Theme.of(context).backgroundColor,
                                tapable: true,
                                onTap: () {
                                  if (_validInputs()) {
                                    Map<String, dynamic> op = {
                                      "delegator": '__signer',
                                      "delegatee": _usernameController.text
                                          .replaceAll('@', ''),
                                      "vesting_shares":
                                          0.00.toString() + ' VESTS',
                                      "redirect_uri": 'https://hiverrr.com'
                                    };

                                    //TODO: make sure to get delegation transfer
                                    Uri uri = hc.getHivesignerSignUrl(
                                        type: 'delegate_vesting_shares',
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
                      widget.changingDelegation
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
                            //TODO: amount to vests
                            if (_validInputs()) {
                              Map<String, dynamic> op = {
                                "delegator": '__signer',
                                "delegatee": _usernameController.text
                                    .replaceAll('@', ''),
                                "vesting_shares":
                                    _amountController.text + ' HP',
                                "redirect_uri": 'https://hiverrr.com'
                              };

                              Uri uri = hc.getHivesignerSignUrl(
                                  type: 'delegate_vesting_shares', params: op);

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
                    widget.changingDelegation
                        ? Container(
                            height: 10,
                          )
                        : Container(),
                    widget.changingDelegation
                        ? Container(
                            padding: myEdgeInsets.leftRight,
                            child: Text(
                              'Canceling a delegation takes 5 days to process',
                              style: TextStyle(fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Container(),
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
    );
  }
}
