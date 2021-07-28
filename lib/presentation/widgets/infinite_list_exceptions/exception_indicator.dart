import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Basic layout for indicating that an exception occurred.
class ExceptionIndicator extends StatelessWidget {
  const ExceptionIndicator({
    required this.title,
    required this.message,
    this.onTryAgain,
    Key? key,
  })  : assert(title != null),
        //assert(assetName != null),
        super(key: key);
  final String title;
  final String message;
  final VoidCallback? onTryAgain;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Column(
            children: [
              const SizedBox(
                height: 32,
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (message != null)
                const SizedBox(
                  height: 16,
                ),
              if (message != null)
                Text(
                  message,
                  textAlign: TextAlign.center,
                ),
              if (onTryAgain != null) const Spacer(),
              if (onTryAgain != null)
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: GestureDetector(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).accentColor),
                      onPressed: onTryAgain,
                      icon: const Icon(
                        Icons.refresh,
                      ),
                      label: const Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
}
