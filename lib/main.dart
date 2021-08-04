import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiverrr/blocs/delegations_bloc/delegations_bloc.dart';
import 'package:hiverrr/blocs/subscriptions_bloc/subscriptions_bloc.dart';
import 'package:hiverrr/blocs/transaction_history_bloc/transaction_history_bloc.dart';
import 'package:hiverrr/blocs/userbalance_bloc.dart/userbalance_bloc.dart';
import 'package:hiverrr/constants/constants.dart';
import 'package:hiverrr/data/hive_calls/hive_calls.dart';
import 'package:hiverrr/data/models/subscription_model.dart';
import 'package:hiverrr/presentation/receive/receive.dart';
import 'package:hiverrr/presentation/send/send.dart';
import 'package:hiverrr/presentation/subscriptions/subscription.dart';
import 'package:hiverrr/presentation/subscriptions/subscriptions.dart';
import 'package:hiverrr/presentation/transactions/transactions.dart';
import 'package:hiverrr/presentation/widgets/auth/ask_login.dart';
import 'package:hiverrr/presentation/widgets/info_widgets/estimated_info.dart';
import 'package:hiverrr/presentation/widgets/info_widgets/savings_info.dart';
import 'package:hiverrr/presentation/widgets/info_widgets/spending_info.dart';
import 'package:hiverrr/presentation/widgets/info_widgets/staking_info.dart';
import 'package:hiverrr/presentation/widgets/neumorphism/neumorphism_container.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:recase/recase.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'blocs/authbloc/auth_bloc.dart';
import 'blocs/theming_bloc/theming_bloc.dart';

void main() {
  runApp(MyAppStart());
}

class MyAppStart extends StatelessWidget {
  const MyAppStart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool light = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemingBloc()..add(LoadTheme())),
        BlocProvider(
          create: (context) => AuthBloc()..add(TryLogInFromToken()),
        ),
        BlocProvider(create: (context) => UserbalanceBloc()),
        BlocProvider(create: (context) => SubscriptionsBloc()),
        BlocProvider(create: (context) => TransactionHistoryBloc()),
        BlocProvider(create: (context) => DelegationsBloc())
      ],
      child: MaterialApp(
        title: 'Hiverrr',
        builder: BotToastInit(),
        navigatorObservers: [BotToastNavigatorObserver()],
        theme: light ? themeDatas.lightTheme : themeDatas.darkTheme,
        home: BlocListener<ThemingBloc, ThemingState>(
          listener: (context, state) {
            if (state is ThemeLoaded) {
              setState(() {
                light = state.light;
              });
            }
          },
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              // TODO: implement listener
              if (state is LoggedIn) {
                BlocProvider.of<UserbalanceBloc>(context)
                    .add(GetUserBalance(username: state.user.username));
                /* BlocProvider.of<SubscriptionsBloc>(context).add(
                    FetchSubscriptions(
                        pageKey: 0, username: state.user.username)); */
              }
            },
            child: MyHomePage(),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  showUserOptions({required String username}) {
    showMaterialModalBottomSheet(
        useRootNavigator: true,
        duration: Duration(milliseconds: 150),
        expand: false,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) {
          List<Widget> columnItems = [];

          columnItems.add(GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop();
                BlocProvider.of<AuthBloc>(context).add(LogOut());
              },
              child: Container(
                padding: myEdgeInsets.bottomLeftRight,
                child: Text(
                  'Log out',
                ),
              )));

          columnItems.add(GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop();
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
              },
              child: Container(
                padding: myEdgeInsets.bottomLeftRight,
                child: Text(
                  'Switch account',
                ),
              )));

          columnItems.add(GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop();
                launch('https://peakd.com/@' + username);
              },
              child: Container(
                padding: myEdgeInsets.bottomLeftRight,
                child: Text(
                  'Vist profile',
                ),
              )));

          return Container(
            decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            padding: EdgeInsets.only(top: 20),
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: columnItems,
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is LoggedIn) {
          return Container(
            child: RefreshIndicator(
              onRefresh: () async {
                BlocProvider.of<UserbalanceBloc>(context)
                    .add(GetUserBalance(username: state.user.username));
              },
              child: ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  Container(
                    height: 25,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      width: 90,
                      height: 90,
                      child: NeumorphismContainer(
                          tapable: true,
                          margin: EdgeInsets.all(0),
                          padding: EdgeInsets.all(10),
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          color: Theme.of(context).backgroundColor,
                          onTap: () {
                            showUserOptions(username: state.user.username);
                          },
                          mainContent: Container(
                            /*      height: 50,
                                        width: 50, */
                            child: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).backgroundColor,
                              backgroundImage: CachedNetworkImageProvider(
                                state.user.profilepic,
                              ),
                            ),
                          ),
                          expandableContent: Container()),
                    ),
                  ]),
                  Container(
                    height: 25,
                  ),
                  Row(children: [
                    Expanded(
                      child: NeumorphismContainer(
                        color: Theme.of(context).backgroundColor,
                        tapable: true,
                        onTap: () {
                          showUserOptions(username: state.user.username);
                        },
                        mainContent: Center(
                          child: Text(
                            'Welcome back ' +
                                state.user.username.sentenceCase +
                                ' 👋',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
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
                  Row(
                    children: [
                      Container(
                        width: 25,
                      ),
                      Expanded(
                        child: NeumorphismContainer(
                          margin: EdgeInsets.all(0),
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                          tapable: true,
                          color: Theme.of(context).accentColor,
                          expandableContent: Container(),
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(builder: (_) => SendPage()));
                          },
                          mainContent: Text('Send',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              )),
                        ),
                      ),
                      Container(
                        width: 25,
                      ),
                      Expanded(
                        child: NeumorphismContainer(
                          margin: EdgeInsets.all(0),
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                          tapable: true,
                          color: Theme.of(context).accentColor,
                          expandableContent: Container(),
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                    builder: (_) => ReceivePage()));
                          },
                          mainContent: Text('Receive',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              )),
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
                  Row(children: [
                    Expanded(
                      child: NeumorphismContainer(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                          color: Theme.of(context).accentColor,
                          tapable: true,
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                    builder: (_) => SubscriptionsPage(
                                        username: state.user.username)));
                          },
                          mainContent: Text('Subscriptions',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              )),
                          expandableContent: Container()),
                    ),
                  ]),
                  Container(
                    height: 25,
                  ),
                  Row(children: [
                    Expanded(
                      child: NeumorphismContainer(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                          color: Theme.of(context).backgroundColor,
                          tapable: true,
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                    builder: (_) => TransactionsPage(
                                        username: state.user.username)));
                          },
                          mainContent: Text('Transaction history',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              )),
                          expandableContent: Container()),
                    ),
                  ]),
                  Container(
                    height: 25,
                  ),
                  BlocBuilder<UserbalanceBloc, UserbalanceState>(
                    builder: (context, state) {
                      if (state is UserBalancedLoaded) {
                        return Column(
                          children: [
                            SpendingInfo(
                              userBalance: state.userBalance,
                            ),
                            Container(
                              height: 25,
                            ),
                            SavingsInfo(
                              userBalance: state.userBalance,
                            ),
                            Container(
                              height: 25,
                            ),
                            StakingInfo(
                              userBalance: state.userBalance,
                            ),
                            Container(
                              height: 25,
                            ),
                            EstimatedInfo(userBalance: state.userBalance),
                            Container(
                              height: 25,
                            ),
                          ],
                        );
                      }
                      if (state is UserBalanceError) {
                        //TODO
                        return Container(
                          child: Text('Something broke hard'),
                        );
                      }
                      return Column(
                        children: [
                          Stack(children: [
                            Container(
                              child: NeumorphismContainer(
                                padding: EdgeInsets.fromLTRB(20, 15, 20, 25),
                                color: Theme.of(context).backgroundColor,
                                onTap: () {},
                                expandableContent: Container(),
                                mainContent: Shimmer.fromColors(
                                  baseColor: Theme.of(context).backgroundColor,
                                  highlightColor:
                                      BlocProvider.of<ThemingBloc>(context)
                                              .light
                                          ? Colors.white
                                          : Colors.white10,
                                  child: Container(
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Spending account',
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
                                            text: '0.000',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2!
                                                .copyWith(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ])),
                                        Container(
                                          height: 15,
                                        ),
                                        RichText(
                                            text: TextSpan(children: [
                                          TextSpan(
                                            text: 'HBD:   ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2!
                                                .copyWith(fontSize: 18),
                                          ),
                                          TextSpan(
                                            text: '0.000',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2!
                                                .copyWith(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ])),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(45, 15, 20, 15),
                              child: Text(
                                'Spending account',
                              ),
                            )
                          ]),
                          Container(
                            height: 25,
                          ),
                          Stack(children: [
                            Container(
                              child: NeumorphismContainer(
                                padding: EdgeInsets.fromLTRB(20, 15, 20, 25),
                                color: Theme.of(context).backgroundColor,
                                onTap: () {},
                                expandableContent: Container(),
                                mainContent: Shimmer.fromColors(
                                  baseColor: Theme.of(context).backgroundColor,
                                  highlightColor:
                                      BlocProvider.of<ThemingBloc>(context)
                                              .light
                                          ? Colors.white
                                          : Colors.white10,
                                  child: Container(
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Savings account',
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
                                            text: '0.000',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2!
                                                .copyWith(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ])),
                                        Container(
                                          height: 15,
                                        ),
                                        RichText(
                                            text: TextSpan(children: [
                                          TextSpan(
                                            text: 'HBD:   ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2!
                                                .copyWith(fontSize: 18),
                                          ),
                                          TextSpan(
                                            text: '0.000',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2!
                                                .copyWith(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ])),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(45, 15, 20, 15),
                              child: Text(
                                'Savings account',
                              ),
                            )
                          ]),
                          Container(
                            height: 25,
                          ),
                          Stack(children: [
                            Container(
                              child: NeumorphismContainer(
                                padding: EdgeInsets.fromLTRB(20, 15, 20, 25),
                                color: Theme.of(context).backgroundColor,
                                onTap: () {},
                                expandableContent: Container(),
                                mainContent: Shimmer.fromColors(
                                  baseColor: Theme.of(context).backgroundColor,
                                  highlightColor:
                                      BlocProvider.of<ThemingBloc>(context)
                                              .light
                                          ? Colors.white
                                          : Colors.white10,
                                  child: Container(
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            text: '0.000',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2!
                                                .copyWith(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ])),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(45, 15, 20, 15),
                              child: Text(
                                'Staking account',
                              ),
                            )
                          ]),
                          Container(
                            height: 25,
                          ),
                          Stack(children: [
                            Container(
                              child: NeumorphismContainer(
                                padding: EdgeInsets.fromLTRB(20, 15, 20, 25),
                                color: Theme.of(context).backgroundColor,
                                onTap: () {},
                                expandableContent: Container(),
                                mainContent: Shimmer.fromColors(
                                  baseColor: Theme.of(context).backgroundColor,
                                  highlightColor:
                                      BlocProvider.of<ThemingBloc>(context)
                                              .light
                                          ? Colors.white
                                          : Colors.white10,
                                  child: Container(
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Estimated account value',
                                        ),
                                        Container(
                                          height: 25,
                                        ),
                                        RichText(
                                            text: TextSpan(children: [
                                          TextSpan(
                                            text: 'USD:   ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2!
                                                .copyWith(fontSize: 18),
                                          ),
                                          TextSpan(
                                            text: '0.00',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2!
                                                .copyWith(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ])),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(45, 15, 20, 15),
                              child: Text(
                                'Estimated account value',
                              ),
                            )
                          ]),
                          Container(
                            height: 25,
                          )
                        ],
                      );
                    },
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
                          Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                  builder: (_) => Subscription(
                                      subscription: SubscriptionModel(
                                          username: 'martibis',
                                          memo:
                                              'Thanks for buying me a coffee every month (:',
                                          profilepic:
                                              'https://images.ecency.com/webp/u/martibis/avatar/medium',
                                          amount: 5,
                                          currency: 'HBD',
                                          reccurenceString: 'Monthly',
                                          recurrence: HOURSPERMONTH,
                                          remainingExecutions: 23))));
                        },
                        mainContent: Text(
                          '☕',
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
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
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
                              light: !BlocProvider.of<ThemingBloc>(context)
                                  .light));
                        },
                        mainContent: Text(
                          BlocProvider.of<ThemingBloc>(context).light
                              ? '🌘'
                              : '☀',
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
                  ),
                ],
              ),
            ),
          ); //Text(state.user.username);
        }
        if (state is Loading) {
          return Text('Loading');
        }

        return AskLogin();
      },
    )));
  }
}
