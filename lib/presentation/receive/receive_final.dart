import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiverrr/blocs/authbloc/auth_bloc.dart';
import 'package:hiverrr/blocs/userbalance_bloc.dart/userbalance_bloc.dart';
import 'package:hiverrr/constants/constants.dart';
import 'package:hiverrr/data/hive_calls/hive_calls.dart';
import 'package:hiverrr/presentation/widgets/neumorphism/neumorphism_container.dart';
import 'package:hiverrr/presentation/widgets/screen_header/screen_header.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiveFinalPage extends StatefulWidget {
  final String hiveSignerUrl;
  ReceiveFinalPage({
    Key? key,
    required this.hiveSignerUrl,
  }) : super(key: key);

  @override
  _ReceiveFinalPageState createState() => _ReceiveFinalPageState();
}

class _ReceiveFinalPageState extends State<ReceiveFinalPage> {
  Timer? timer;
  HiveCalls hc = HiveCalls();
  //TODO: look into this
  /* checkIfReceived() async {
    Uri hsu = Uri.parse(widget.hiveSignerUrl);
    const duration = const Duration(seconds: 1);
    timer = new Timer.periodic(duration, (Timer t) async {
      bool isReceived = await hc.lastTransactions(
          username: hsu.queryParameters['to']!,
          amount: hsu.queryParameters['amount']!.split(' ')[0],
          memo: hsu.queryParameters['memo']!,
          nai: hsu.queryParameters['amount']!.split(' ')[1] == "HIVE"
              ? HIVENAI
              : HBDNAI);
      if (isReceived) {
        BotToast.showText(
          crossPage: false,
          text: "Payment received 🤑",
          textStyle: TextStyle(color: Colors.white),
          borderRadius: BorderRadius.circular(4),
        );
        t.cancel();
        timer!.cancel();
      }
    });
  } */

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  @override
  void initState() {
    //TODO: look into this
    /* checkIfReceived(); */
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  ScreenHeader(title: '', hasBackButton: true),
                  NeumorphismContainer(
                      color: Theme.of(context).backgroundColor,
                      onTap: () {},
                      tapable: false,
                      expandable: false,
                      mainContent: Column(children: [
                        Text(
                          'Scan to pay',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Container(
                          height: 20,
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(10),
                            child: QrImage(
                              data: widget.hiveSignerUrl,
                              size: 200,
                              backgroundColor: Colors.white,
                              /* foregroundColor:
                                  Theme.of(context).textTheme.bodyText1!.color, */
                            ),
                          ),
                        ),
                        Container(
                          height: 20,
                        ),
                      ]),
                      expandableContent: Container()),
                ],
              ),
            ),
            Row(children: [
              Expanded(
                child: NeumorphismContainer(
                    color: Theme.of(context).backgroundColor,
                    onTap: () {
                      Clipboard.setData(
                              new ClipboardData(text: widget.hiveSignerUrl))
                          .then((_) {
                        BotToast.showText(
                          crossPage: false,
                          text: "Link is copied to clipboard 💸",
                          textStyle: TextStyle(color: Colors.white),
                          borderRadius: BorderRadius.circular(4),
                        );
                      });
                    },
                    tapable: true,
                    expandable: false,
                    mainContent: Text(
                      'Share link',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    expandableContent: Container()),
              ),
            ]),
            Container(
              height: 25,
            ),
            Row(children: [
              Expanded(
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is LoggedIn)
                      return NeumorphismContainer(
                        color: Theme.of(context).accentColor,
                        tapable: true,
                        onTap: () {
                          BlocProvider.of<UserbalanceBloc>(context).add(
                              GetUserBalance(username: state.user.username));
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                        mainContent: Center(
                          child: Text(
                            'Done',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        expandableContent: Container(),
                        expandable: false,
                      );
                    return Container();
                  },
                ),
              ),
            ]),
            Container(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }
}
