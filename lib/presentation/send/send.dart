import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiverrr/blocs/authbloc/auth_bloc.dart';
import 'package:hiverrr/blocs/userbalance_bloc.dart/userbalance_bloc.dart';
import 'package:hiverrr/constants/constants.dart';
import 'package:hiverrr/presentation/send/manual_transfer.dart';
import 'package:hiverrr/presentation/widgets/neumorphism/neumorphism_container.dart';
import 'package:hiverrr/presentation/widgets/screen_header/screen_header.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SendPage extends StatefulWidget {
  SendPage({
    Key? key,
  }) : super(key: key);

  @override
  _SendPageState createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  WebViewController? webViewController;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code.contains('hivesigner')) {
        controller.pauseCamera();
        confirmTransaction(scanData.code);
      }
    });
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  confirmTransaction(String url) {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    BotToast.showAnimationWidget(
        clickClose: false,
        allowClick: false,
        onlyOne: true,
        crossPage: true,
        enableKeyboardSafeArea: true,
        backButtonBehavior: BackButtonBehavior.close,
        onClose: () {
          controller!.resumeCamera();
        },
        wrapToastAnimation: (controller, cancel, child) => Stack(
              children: <Widget>[
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    cancel();
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
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is LoggedIn)
                      return SafeArea(
                        child: Container(
                          padding: EdgeInsets.only(top: 50),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10)),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10))),
                              child: WebView(
                                javascriptMode: JavascriptMode.unrestricted,
                                initialUrl: url.toString(),
                                onPageStarted: (url) {
                                  Uri uri = Uri.parse(url);
                                  //this means succesful transfer
                                  if (uri.host.contains('hiverrr')) {
                                    BotToast.showText(
                                      crossPage: true,
                                      text: "Transfer was succesful! 🤩",
                                      textStyle: TextStyle(color: Colors.white),
                                      borderRadius: BorderRadius.circular(4),
                                    );
                                    BlocProvider.of<UserbalanceBloc>(context)
                                        .add(GetUserBalance(
                                            username: state.user.username));
                                    cancel();
                                    //Navigator.of(context).pop();
                                  }
                                },
                                onWebViewCreated: (controller) {
                                  webViewController = controller;
                                },
                                onProgress: (progress) async {
                                  String? url =
                                      await webViewController!.currentUrl();
                                  if (url == 'https://hivesigner.com/' ||
                                      url == 'https://hivesigner.com') {
                                    cancel();
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    return Container();
                  },
                )
              ],
            ),
        toastBuilder: (cancelFunc) => AlertDialog(),
        animationDuration: Duration(milliseconds: 0));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(children: [
      ScreenHeader(title: 'Send', hasBackButton: true),
      NeumorphismContainer(
          padding: EdgeInsets.all(20),
          color: Theme.of(context).backgroundColor,
          onTap: () {},
          mainContent: Column(
            children: [
              Text(
                'Scan QR code',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Container(
                height: 20,
              ),
              Container(
                height: 300,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: QRView(
                    overlay: QrScannerOverlayShape(
                        overlayColor: Colors.black54,
                        borderColor: Colors.white,
                        borderWidth: 10),
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                  ),
                ),
              ),
              /* Container(
                child: Center(
                  child: (result != null)
                      ? Text(
                          'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                      : Text('Scan a code'),
                ),
              ), */
            ],
          ),
          expandableContent: Container()),
      Container(
        height: 25,
      ),
      Row(children: [
        Expanded(
          child: NeumorphismContainer(
              color: Theme.of(context).backgroundColor,
              tapable: true,
              onTap: () {
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (_) => ManualTransfer()));
              },
              mainContent: Text(
                'Manual transfer',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              expandableContent: Container()),
        ),
      ]),
      Container(
        height: 25,
      ),
    ])));
  }
}
