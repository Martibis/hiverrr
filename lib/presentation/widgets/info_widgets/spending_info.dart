import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:hiverrr/data/models/user_balance_model.dart';
import 'package:hiverrr/presentation/widgets/neumorphism/neumorphism_container.dart';

class SpendingInfo extends StatelessWidget {
  final UserBalance userBalance;
  const SpendingInfo({Key? key, required this.userBalance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeumorphismContainer(
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                text: userBalance.hivebalance.toString(),
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
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
                text: userBalance.hbdbalance.toString(),
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
