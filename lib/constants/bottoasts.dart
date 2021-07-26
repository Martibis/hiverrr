import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

class BotToasts {
  void tos(
    BackButtonBehavior backButtonBehavior, {
    VoidCallback? cancel,
    VoidCallback? confirm,
    VoidCallback? backgroundReturn,
    BuildContext? context,
  }) async {
    BotToast.showAnimationWidget(
        clickClose: false,
        allowClick: false,
        onlyOne: true,
        crossPage: true,
        backButtonBehavior: backButtonBehavior,
        toastBuilder: (cancelFunc) => AlertDialog(),
        animationDuration: Duration(milliseconds: 0),
        wrapToastAnimation: (controller, cancel, child) => SafeArea(
              child: Stack(children: <Widget>[
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    cancel();
                    backgroundReturn?.call();
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
                SafeArea(
                    child: Container(
                        padding: EdgeInsets.only(top: 50),
                        child: Container(
                          decoration: BoxDecoration(
                              color: context != null
                                  ? Theme.of(context).backgroundColor
                                  : Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10))),
                          padding: EdgeInsets.all(20),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('This will be the TOS')
                                        ]),
                                  ),
                                ),
                                Container(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Row(
                                      children: [
                                        GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () {
                                            cancel();
                                          },
                                          child: Text(
                                            'back',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      ],
                                    )),
                                    Expanded(
                                        child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () async {
                                            await STORAGE.write(
                                                key: 'tos', value: 'yes');
                                            confirm!();
                                            cancel();
                                          },
                                          child: Text(
                                            'accept',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      ],
                                    ))
                                  ],
                                )
                              ]),
                        )))
              ]),
            ));
  }
}
