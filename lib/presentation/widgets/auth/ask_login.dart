import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiverrr/blocs/authbloc/auth_bloc.dart';
import 'package:hiverrr/blocs/theming_bloc/theming_bloc.dart';
import 'package:hiverrr/constants/constants.dart';
import 'package:hiverrr/constants/sign_in_icons_icons.dart';
import 'package:hiverrr/presentation/widgets/neumorphism/neumorphism_container.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AskLogin extends StatefulWidget {
  final String loginMessage;
  AskLogin({
    this.loginMessage = 'Please log in / register',
    Key? key,
  }) : super(key: key);

  @override
  _AskLoginState createState() => _AskLoginState();
}

class _AskLoginState extends State<AskLogin> {
  Future<bool> _termsOfServiceAccepted() async {
    String? acceptedTos = await STORAGE.read(key: 'tos');
    if (acceptedTos == 'yes') {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Expanded(
        child: Container(
          height: 25,
        ),
      ),
      Text(
        'Hiverrr.',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
      ),
      Text(
        'The only wallet a Hiveian needs!',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
      Container(
        height: 25,
      ),
      Container(
          padding: myEdgeInsets.standardAll,
          child: SizedBox(
              width: 250,
              height: 225,
              child: Image.asset(BlocProvider.of<ThemingBloc>(context).light
                  ? 'assets/hive_white.png'
                  : 'assets/hive_black.png'))),
      Container(
        height: 25,
      ),
      NeumorphismContainer(
          tapable: true,
          color: Theme.of(context).backgroundColor,
          expandableContent: Container(),
          mainContent: Container(
            //width: 210,
            //height: 45,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(SignInIcons.hive,
                  size: 18,
                  color: BlocProvider.of<ThemingBloc>(context).light
                      ? Colors.black
                      : Colors.white),
              Container(
                width: 15,
              ),
              Text(
                'Sign in with Hivesigner',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                width: 15,
              )
            ]),
          ),
          onTap: () async {
            bool tosAccepted = await _termsOfServiceAccepted();
            //TODO: later remove this (when TOS is done)
            tosAccepted = true;
            if (tosAccepted == true) {
              if (Platform.isAndroid)
                WebView.platform = SurfaceAndroidWebView();
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
                                decoration:
                                    BoxDecoration(color: myColors.black90),
                                child: SizedBox.expand(),
                              ),
                              animation: controller,
                            ),
                          ),
                          SafeArea(
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
                                    initialUrl:
                                        'https://hivesigner.com/oauth2/authorize?client_id=hiverrr&redirect_uri=https%3A%2F%2Fhiverrr.com&scope=login',
                                    onPageStarted: (url) {
                                      Uri uri = Uri.parse(url);
                                      if (uri.queryParameters
                                              .containsKey('access_token') &&
                                          uri.queryParameters
                                              .containsKey('username')) {
                                        String? username =
                                            uri.queryParameters['username'];
                                        BlocProvider.of<AuthBloc>(context).add(
                                            HiveLogin(
                                                username: username != null
                                                    ? username
                                                    : ''));
                                        cancel();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                  toastBuilder: (cancelFunc) => AlertDialog(),
                  animationDuration: Duration(milliseconds: 0));
            } else {
              botToasts.tos(BackButtonBehavior.close, context: context,
                  confirm: () {
                if (Platform.isAndroid)
                  WebView.platform = SurfaceAndroidWebView();
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
                                  decoration:
                                      BoxDecoration(color: myColors.black90),
                                  child: SizedBox.expand(),
                                ),
                                animation: controller,
                              ),
                            ),
                            SafeArea(
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
                                      javascriptMode:
                                          JavascriptMode.unrestricted,
                                      initialUrl:
                                          'https://hivesigner.com/oauth2/authorize?client_id=hiverrr&redirect_uri=https%3A%2F%2Fhiverrr.com&scope=login',
                                      onPageStarted: (url) {
                                        Uri uri = Uri.parse(url);
                                        if (uri.queryParameters
                                                .containsKey('access_token') &&
                                            uri.queryParameters
                                                .containsKey('username')) {
                                          String? username =
                                              uri.queryParameters['username'];
                                          BlocProvider.of<AuthBloc>(context)
                                              .add(HiveLogin(
                                                  username: username != null
                                                      ? username
                                                      : ''));
                                          cancel();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                    toastBuilder: (cancelFunc) => AlertDialog(),
                    animationDuration: Duration(milliseconds: 0));
              });
            }
          }),
      Container(
        height: 10,
      ),
      Container(
          padding: myEdgeInsets.leftRight,
          child: Text('For transacting sign in with your active key')),
      Expanded(
        child: Container(
          height: 25,
        ),
      ),
      /*  Cotainner(
        height: 25,
      ),
      Container(
        padding: myEdgeInsets.leftRight,
        child: Text(
          "Welcome to Hiverrr, the only wallet a Hiveian needs.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ), */
      Container(
        height: 25,
      ),
      Row(children: [
        Container(
          width: 25,
        ),
        NeumorphismContainer(
            margin: EdgeInsets.all(0),
            padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
            color: Theme.of(context).backgroundColor,
            tapable: true,
            onTap: () {
              launch('https://github.com/Martibis/hiverrr');
            },
            mainContent: Text(
              '🤓',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            expandableContent: Container()),
        Container(
          width: 25,
        ),
        Expanded(
          child: NeumorphismContainer(
              margin: EdgeInsets.all(0),
              padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
              color: Theme.of(context).backgroundColor,
              tapable: true,
              onTap: () {
                launch('https://peakd.com/@martibis');
              },
              mainContent: Text(
                'Made with ❤️ by Martibis',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              expandableContent: Container()),
        ),
        Container(
          width: 25,
        ),
        NeumorphismContainer(
            margin: EdgeInsets.all(0),
            padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
            color: Theme.of(context).backgroundColor,
            tapable: true,
            onTap: () {
              BlocProvider.of<ThemingBloc>(context).add(SetTheme(
                  light: !BlocProvider.of<ThemingBloc>(context).light));
            },
            mainContent: Text(
              BlocProvider.of<ThemingBloc>(context).light ? '🌘' : '☀',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            expandableContent: Container()),
        Container(
          width: 25,
        )
      ]),
      Container(
        height: 25,
      )
    ]);
  }
}
