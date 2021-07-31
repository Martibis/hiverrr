import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiverrr/blocs/authbloc/auth_bloc.dart';
import 'package:hiverrr/blocs/userbalance_bloc.dart/userbalance_bloc.dart';
import 'package:hiverrr/constants/constants.dart';
import 'package:hiverrr/presentation/widgets/auth/ask_login.dart';
import 'package:hiverrr/presentation/widgets/neumorphism/neumorphism_container.dart';
import 'package:hiverrr/presentation/widgets/screen_header/screen_header.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PowerUp extends StatefulWidget {
  final String? amount;
  final String maxHive;

  PowerUp({Key? key, this.amount, required this.maxHive}) : super(key: key);

  @override
  _PowerUpState createState() => _PowerUpState();
}

class _PowerUpState extends State<PowerUp> {
  GlobalKey<FormState> _sendFormKey = GlobalKey<FormState>();
  TextEditingController _amountController = TextEditingController();
  WebViewController? webViewController;

  confirmTransaction(String url) {
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
                                      text: "Power up was succesful! 🤩",
                                      textStyle: TextStyle(color: Colors.white),
                                      borderRadius: BorderRadius.circular(4),
                                    );
                                    BlocProvider.of<UserbalanceBloc>(context)
                                        .add(GetUserBalance(
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
    if (_sendFormKey.currentState!.validate()) {
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
    _amountController.text = (widget.amount == null ? '' : widget.amount)!;
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
                key: _sendFormKey,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        physics: BouncingScrollPhysics(),
                        children: [
                          ScreenHeader(title: 'Power up', hasBackButton: true),
                          Container(
                            padding: myEdgeInsets.leftRight,
                            child: Row(children: [
                              Expanded(
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
                                    helperText: 'HIVE to power up',
                                    hintText: '10.00',
                                  ),
                                  //textAlign: TextAlign.center,
                                ),
                              ),
                              NeumorphismContainer(
                                margin: EdgeInsets.fromLTRB(25, 0, 0, 20),
                                color: Theme.of(context).backgroundColor,
                                onTap: () {
                                  _amountController.text = widget.maxHive;
                                },
                                mainContent: Text('max'),
                                expandableContent: Container(),
                                expandable: false,
                                tapable: true,
                              )
                            ]),
                          ),
                          Container(
                            height: 25,
                          ),
                        ],
                      ),
                    ),
                    Row(children: [
                      Expanded(
                        child: NeumorphismContainer(
                          color: Theme.of(context).accentColor,
                          tapable: true,
                          onTap: () {
                            if (_validInputs()) {
                              Map<String, dynamic> op = {
                                "from": '__signer',
                                "to": '__signer',
                                "amount": _amountController.text + ' HIVE',
                                "redirect_uri": 'https://hiverrr.com'
                              };
                              Uri uri = hc.getHivesignerSignUrl(
                                  type: 'transfer_to_vesting', params: op);

                              if (FocusScope.of(context).isFirstFocus) {
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                              }
                              confirmTransaction(uri.toString());
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
                    ]),
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
