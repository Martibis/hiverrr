import 'package:flutter/material.dart';
import 'package:hiverrr/constants/constants.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final bool hasBackButton;
  final IconData backIcon;
  const ScreenHeader(
      {Key? key,
      required this.title,
      required this.hasBackButton,
      this.backIcon = Icons.arrow_back})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: myEdgeInsets.standardAll,
      child: Row(
        children: [
          hasBackButton
              ? GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    padding: EdgeInsets.fromLTRB(0, 5, 25, 5),
                    child: Icon(backIcon,
                        color: Theme.of(context).textTheme.bodyText1!.color,
                        size: 25),
                  ),
                )
              : Container(),
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
