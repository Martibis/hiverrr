import 'package:flutter/cupertino.dart';
import 'exception_indicator.dart';

/// Indicates that no items were found.
class EmptyListIndicator extends StatelessWidget {
  final String title;
  final String message;

  const EmptyListIndicator(
      {Key? key, this.title = '', this.message = 'We couldn\'t find anything'})
      : super(key: key);

  @override
  Widget build(BuildContext context) => ExceptionIndicator(
        title: title,
        message: message,
        onTryAgain: null,
      );
}
