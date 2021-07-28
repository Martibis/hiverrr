import 'package:flutter/cupertino.dart';

import 'exception_indicator.dart';

class LoadingMoreIndicator extends StatelessWidget {
  final String message;
  final String title;
  const LoadingMoreIndicator(
      {Key? key,
      this.onTryAgain,
      this.message = 'Loading more',
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
