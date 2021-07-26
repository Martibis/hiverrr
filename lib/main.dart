import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiverrr/blocs/userbalance_bloc.dart/userbalance_bloc.dart';
import 'package:hiverrr/constants/constants.dart';
import 'package:hiverrr/presentation/receive/receive.dart';
import 'package:hiverrr/presentation/send/manual_transfer.dart';
import 'package:hiverrr/presentation/send/send.dart';
import 'package:hiverrr/presentation/widgets/auth/ask_login.dart';
import 'package:hiverrr/presentation/widgets/neumorphism/neumorphism_container.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:recase/recase.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

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
  //AuthBloc authBloc = AuthBloc();
  bool light = true;
  @override
  void initState() {
    //authBloc.add(TryLogInFromToken());
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
        BlocProvider(create: (context) => UserbalanceBloc())
      ],
      child: BlocListener<ThemingBloc, ThemingState>(
        listener: (context, state) {
          if (state is ThemeLoaded) {
            print('here');
            print(state.light);
            setState(() {
              light = state.light;
            });
          }
        },
        child: MaterialApp(
          title: 'Hiverrr',
          builder: BotToastInit(),
          navigatorObservers: [BotToastNavigatorObserver()],
          theme: light ? themeDatas.lightTheme : themeDatas.darkTheme,
          home: MyHomePage(),
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LoggedIn) {
          BlocProvider.of<UserbalanceBloc>(context)
              .add(GetUserBalance(username: state.user.username));
        }
      },
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
                            showMaterialModalBottomSheet(
                                useRootNavigator: true,
                                duration: Duration(milliseconds: 150),
                                expand: false,
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (context) {
                                  List<Widget> columnItems = [];

                                  columnItems.add(GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                        BlocProvider.of<AuthBloc>(context)
                                            .add(LogOut());
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
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                        launch('https://peakd.com/@' +
                                            state.user.username);
                                      },
                                      child: Container(
                                        padding: myEdgeInsets.bottomLeftRight,
                                        child: Text(
                                          'Vist profile',
                                        ),
                                      )));

                                  return Container(
                                    decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).backgroundColor,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10))),
                                    padding: EdgeInsets.only(top: 20),
                                    child: Column(
                                      //mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: columnItems,
                                    ),
                                  );
                                });
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
                          showMaterialModalBottomSheet(
                              useRootNavigator: true,
                              duration: Duration(milliseconds: 150),
                              expand: false,
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) {
                                List<Widget> columnItems = [];

                                columnItems.add(GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                      BlocProvider.of<AuthBloc>(context)
                                          .add(LogOut());
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
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                      launch('https://peakd.com/@' +
                                          state.user.username);
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: columnItems,
                                  ),
                                );
                              });
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
                  BlocBuilder<UserbalanceBloc, UserbalanceState>(
                    builder: (context, state) {
                      if (state is UserBalancedLoaded) {
                        return Column(
                          children: [
                            Container(
                              child: NeumorphismContainer(
                                tapable: true,
                                padding: EdgeInsets.fromLTRB(20, 15, 20, 25),
                                color: Theme.of(context).backgroundColor,
                                onTap: () {
                                  BotToast.showText(
                                    crossPage: false,
                                    text: "Any plans with all that Hive? 🤑",
                                    textStyle: TextStyle(color: Colors.white),
                                    borderRadius: BorderRadius.circular(4),
                                  );
                                },
                                expandableContent: Container(),
                                mainContent: Container(
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
                                          text: state.userBalance.hivebalance
                                              .toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2!
                                              .copyWith(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
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
                                          text: state.userBalance.hbdbalance
                                              .toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2!
                                              .copyWith(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ])),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 25,
                            ),
                            Container(
                              child: NeumorphismContainer(
                                tapable: true,
                                padding: EdgeInsets.fromLTRB(20, 15, 20, 25),
                                color: Theme.of(context).backgroundColor,
                                expandable: true,
                                onTap: () {},
                                //TODO: expandable content
                                expandableContent: Container(
                                    width: double.infinity,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Divider(
                                            height: 50,
                                          ),
                                          RichText(
                                              text: TextSpan(children: [
                                            TextSpan(
                                              text: 'HIVE interest (APR):   ',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2,
                                            ),
                                            TextSpan(
                                              text: state.userBalance
                                                      .hivesavinginterestrate
                                                      .toStringAsFixed(2) +
                                                  '%',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2!
                                                  .copyWith(
                                                      fontWeight: FontWeight
                                                          .bold,
                                                      color:
                                                          state.userBalance
                                                                      .hivesavinginterestrate >
                                                                  0
                                                              ? Theme.of(
                                                                      context)
                                                                  .highlightColor
                                                              : Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyText2!
                                                                  .color),
                                            ),
                                          ])),
                                          Container(
                                            height: 15,
                                          ),
                                          RichText(
                                              text: TextSpan(children: [
                                            TextSpan(
                                              text: 'HBD interest rate:   ',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2,
                                            ),
                                            TextSpan(
                                              text: state.userBalance
                                                      .hbdsavinginterestrate
                                                      .toStringAsFixed(2) +
                                                  '%',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2!
                                                  .copyWith(
                                                      fontWeight: FontWeight
                                                          .bold,
                                                      color:
                                                          state.userBalance
                                                                      .hbdsavinginterestrate >
                                                                  0
                                                              ? Theme.of(
                                                                      context)
                                                                  .highlightColor
                                                              : Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyText2!
                                                                  .color),
                                            ),
                                          ])),
                                        ])),
                                mainContent: Container(
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
                                          text: state
                                              .userBalance.hivesavingsbalance
                                              .toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2!
                                              .copyWith(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
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
                                          text: state
                                              .userBalance.hbdsavingsbalance
                                              .toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2!
                                              .copyWith(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ])),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 25,
                            ),
                            Container(
                              child: NeumorphismContainer(
                                tapable: true,
                                padding: EdgeInsets.fromLTRB(20, 15, 20, 25),
                                color: Theme.of(context).backgroundColor,
                                expandable: true,
                                onTap: () {},
                                //TODO: expandable content
                                expandableContent: Container(
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Divider(
                                          height: 50,
                                        ),
                                        RichText(
                                            text: TextSpan(children: [
                                          TextSpan(
                                            text: 'Delegated Hive:   ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2,
                                          ),
                                          TextSpan(
                                            text: state
                                                .userBalance.hivepowerdelegated
                                                .toStringAsFixed(3),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2!
                                                .copyWith(
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
                                            text: 'Received Hive:   ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2,
                                          ),
                                          TextSpan(
                                            text: state
                                                .userBalance.hivepowerreceived
                                                .toStringAsFixed(3),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ])),
                                        Divider(
                                          height: 50,
                                        ),
                                        RichText(
                                            text: TextSpan(children: [
                                          TextSpan(
                                            text: 'HIVE interest (APR):   ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2,
                                          ),
                                          TextSpan(
                                            text: state.userBalance
                                                    .hivestakedinterest
                                                    .toStringAsFixed(2) +
                                                '%',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .highlightColor,
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
                                            text: 'Curation (APR):   ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2,
                                          ),
                                          TextSpan(
                                            text: state.userBalance
                                                    .curationinterest
                                                    .toStringAsFixed(2) +
                                                '%',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .highlightColor,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ])),
                                      ],
                                    )),
                                mainContent: Container(
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
                                          text: state
                                              .userBalance.hivepoweredupbalance
                                              .toStringAsFixed(3),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2!
                                              .copyWith(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ])),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 25,
                            ),
                          ],
                        );
                      }
                      if (state is UserBalanceError) {
                        return Container();
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
                          //TODO: send with receiver martibis?
                          /*  BotToast.showText(
                            crossPage: false,
                            text: "This feature is coming soon 🤩",
                            textStyle: TextStyle(color: Colors.white),
                            borderRadius: BorderRadius.circular(4),
                          ); */
                          Navigator.of(context, rootNavigator: true)
                              .push(MaterialPageRoute(
                                  builder: (_) => ManualTransfer(
                                        username: 'martibis',
                                        amount: '10',
                                        memo:
                                            'Thank you for wanting to donate so we can keep improving Hiverrr!',
                                      )));
                        },
                        mainContent: Text(
                          '🙏',
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
