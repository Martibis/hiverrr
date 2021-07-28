import 'package:flutter/cupertino.dart';

import 'exception_indicator.dart';

class NoMoreItemsIndicator extends StatelessWidget {
  final String message;
  final String title;
  const NoMoreItemsIndicator(
      {Key? key,
      this.onTryAgain,
      this.message = 'Nothing more to see',
      this.title = ''})
      : super(key: key);

  final VoidCallback? onTryAgain;

  @override
  Widget build(BuildContext context) => ExceptionIndicator(
        title: title,
        message: message,
        onTryAgain: onTryAgain,
      );
}
