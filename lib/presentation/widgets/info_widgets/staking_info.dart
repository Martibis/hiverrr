import 'package:flutter/material.dart';
import 'package:hiverrr/data/models/user_balance_model.dart';
import 'package:hiverrr/presentation/widgets/neumorphism/neumorphism_container.dart';
import 'package:timeago/timeago.dart' as timeago;

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
              Divider(
                height: 50,
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
              userBalance.powerDownRate > 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          height: 50,
                        ),
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                            text: 'Powering down ',
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                          TextSpan(
                            text: userBalance.powerDownRate.toStringAsFixed(3) +
                                ' Hive',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: ' ' +
                                timeago.format(userBalance.nextPowerDown,
                                    allowFromNow: true),
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ])),
                      ],
                    )
                  : Container()
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
