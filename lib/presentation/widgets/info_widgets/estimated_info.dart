import 'package:flutter/material.dart';
import 'package:hiverrr/data/models/user_balance_model.dart';
import 'package:hiverrr/presentation/widgets/neumorphism/neumorphism_container.dart';

class EstimatedInfo extends StatelessWidget {
  final UserBalance userBalance;
  const EstimatedInfo({
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
      expandableContent:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Divider(
          height: 50,
        ),
        RichText(
            text: TextSpan(children: [
          TextSpan(
            text: 'USD/HIVE:    ',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          TextSpan(
            text: '\$' + userBalance.hivePrice.toStringAsFixed(2),
            style: Theme.of(context).textTheme.bodyText2!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).highlightColor),
          ),
        ]))
      ]),
      mainContent: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                text: userBalance.estimatedUsdValue.toStringAsFixed(2),
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
