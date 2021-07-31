import 'package:flutter/material.dart';
import 'package:hiverrr/data/models/user_balance_model.dart';
import 'package:hiverrr/presentation/savings/send_to_savings.dart';
import 'package:hiverrr/presentation/savings/withdraw_from_savings.dart';
import 'package:hiverrr/presentation/widgets/neumorphism/neumorphism_container.dart';

class SavingsInfo extends StatelessWidget {
  final UserBalance userBalance;
  const SavingsInfo({
    Key? key,
    required this.userBalance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeumorphismContainer(
      tapable: true,
      padding: EdgeInsets.fromLTRB(20, 15, 20, 25),
      color: Theme.of(context).backgroundColor,
      expandable: true,
      onTap: () {},
      //TODO: expandable content
      expandableContent: Container(
          width: double.infinity,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                text:
                    userBalance.hivesavinginterestrate.toStringAsFixed(2) + '%',
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: userBalance.hivesavinginterestrate > 0
                        ? Theme.of(context).highlightColor
                        : Theme.of(context).textTheme.bodyText2!.color),
              ),
            ])),
            Container(
              height: 15,
            ),
            RichText(
                text: TextSpan(children: [
              TextSpan(
                text: 'HBD interest rate:   ',
                style: Theme.of(context).textTheme.bodyText2,
              ),
              TextSpan(
                text:
                    userBalance.hbdsavinginterestrate.toStringAsFixed(2) + '%',
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: userBalance.hbdsavinginterestrate > 0
                        ? Theme.of(context).highlightColor
                        : Theme.of(context).textTheme.bodyText2!.color),
              ),
            ])),
            userBalance.amountSavingWithdrawals > 0
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      userBalance.totalOfHbdSavingWithdrawals > 0
                          ? Container(
                              height: 15,
                            )
                          : Container(),
                      userBalance.totalOfHbdSavingWithdrawals > 0
                          ? RichText(
                              text: TextSpan(children: [
                              TextSpan(
                                text: 'Withdrawing HBD:   ',
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                              TextSpan(
                                text: userBalance.totalOfHbdSavingWithdrawals
                                    .toStringAsFixed(3),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: userBalance
                                                    .hivesavinginterestrate >
                                                0
                                            ? Theme.of(context).highlightColor
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyText2!
                                                .color),
                              ),
                            ]))
                          : Container(),
                      userBalance.totalOfHiveSavingWithdrawals > 0
                          ? Container(
                              height: 15,
                            )
                          : Container(),
                      userBalance.totalOfHiveSavingWithdrawals > 0
                          ? RichText(
                              text: TextSpan(children: [
                              TextSpan(
                                text: 'Withdrawing HIVE: ',
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                              TextSpan(
                                text: userBalance.totalOfHiveSavingWithdrawals
                                    .toStringAsFixed(3),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: userBalance
                                                    .hivesavinginterestrate >
                                                0
                                            ? Theme.of(context).highlightColor
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyText2!
                                                .color),
                              ),
                            ]))
                          : Container(),
                    ],
                  )
                : Container(),
            Container(
              height: 15,
            ),
            Divider(
              height: 25,
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(
                        builder: (_) => SendToSavings(
                              maxHbd: userBalance.hbdbalance.toString(),
                              maxHive: userBalance.hivebalance.toString(),
                            )));
              },
              child: Container(
                padding: EdgeInsets.only(top: 15),
                child: Text(
                  'Send to savings',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(
                        builder: (_) => WithdrawFromSavings(
                              maxHbd: userBalance.hbdsavingsbalance.toString(),
                              maxHive:
                                  userBalance.hivesavingsbalance.toString(),
                            )));
              },
              child: Container(
                padding: EdgeInsets.only(
                  top: 15,
                ),
                child: Text(
                  'Withdraw from savings',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          ])),
      mainContent: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                text: userBalance.hivesavingsbalance.toString(),
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
                text: userBalance.hbdsavingsbalance.toString(),
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
