import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiverrr/blocs/authbloc/auth_bloc.dart';
import 'package:hiverrr/constants/constants.dart';
import 'package:hiverrr/presentation/receive/receive_final.dart';
import 'package:hiverrr/presentation/widgets/auth/ask_login.dart';
import 'package:hiverrr/presentation/widgets/neumorphism/neumorphism_container.dart';
import 'package:hiverrr/presentation/widgets/screen_header/screen_header.dart';

class ReceivePage extends StatefulWidget {
  ReceivePage({
    Key? key,
  }) : super(key: key);

  @override
  _ReceivePageState createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  bool isHive = true;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _memoController = TextEditingController();

  bool _validInputs() {
    if (_formKey.currentState!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  String? validateNotEmpty(String? value) {
    if (value!.trim().length == 0) {
      return 'Can not be empty';
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is LoggedIn) {
              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        physics: BouncingScrollPhysics(),
                        children: [
                          ScreenHeader(title: 'Receive', hasBackButton: true),
                          Row(
                            children: [
                              Container(
                                width: 25,
                              ),
                              Expanded(
                                child: NeumorphismContainer(
                                  margin: EdgeInsets.all(0),
                                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                                  color: isHive
                                      ? Theme.of(context).accentColor
                                      : Theme.of(context).backgroundColor,
                                  onTap: () {
                                    setState(() {
                                      if (!isHive) {
                                        isHive = !isHive;
                                      }
                                    });
                                  },
                                  mainContent: Text(
                                    'hive',
                                    style: TextStyle(
                                        color: isHive
                                            ? Colors.white
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyText1!
                                                .color,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  expandableContent: Container(),
                                  expandable: false,
                                ),
                              ),
                              Container(
                                width: 25,
                              ),
                              Expanded(
                                child: NeumorphismContainer(
                                  margin: EdgeInsets.all(0),
                                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                                  color: !isHive
                                      ? Theme.of(context).accentColor
                                      : Theme.of(context).backgroundColor,
                                  onTap: () {
                                    setState(() {
                                      if (isHive) {
                                        isHive = !isHive;
                                      }
                                    });
                                  },
                                  mainContent: Text(
                                    'hbd',
                                    style: TextStyle(
                                        color: !isHive
                                            ? Colors.white
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyText1!
                                                .color,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  expandableContent: Container(),
                                  expandable: false,
                                ),
                              ),
                              Container(
                                width: 25,
                              ),
                            ],
                          ),
                          Container(
                            height: 25,
                          ),
                          Container(
                            padding: myEdgeInsets.leftRight,
                            child: TextFormField(
                              controller: _amountController,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: validateNotEmpty,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r"[0-9.]")),
                                TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                  try {
                                    final text = newValue.text;
                                    if (text.isNotEmpty) double.parse(text);
                                    return newValue;
                                  } catch (e) {
                                    //TODO
                                  }
                                  return oldValue;
                                }),
                              ],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '10.00',
                              ),
                              //textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            height: 25,
                          ),
                          Container(
                            padding: myEdgeInsets.leftRight,
                            child: TextFormField(
                              controller: _memoController,
                              minLines: 6,
                              maxLines: 6,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: 'memo',
                              ),
                              //textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            height: 25,
                          ),
                        ],
                      ),
                    ),
                    Row(children: [
                      Expanded(
                        child: NeumorphismContainer(
                          color: Theme.of(context).accentColor,
                          tapable: true,
                          onTap: () {
                            if (_validInputs()) {
                              Map<String, dynamic> op = {
                                "from": '__signer',
                                "to": state.user.username,
                                "amount": _amountController.text +
                                    (isHive ? ' HIVE' : ' HBD'),
                                "memo": _memoController.text,
                                "redirect_uri": 'https://hiverrr.com'
                              };
                              Uri uri = hc.getHivesignerSignUrl(
                                  type: 'transfer', params: op);

                              if (FocusScope.of(context).isFirstFocus) {
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                              }
                              Navigator.of(context, rootNavigator: true)
                                  .push(MaterialPageRoute(
                                      builder: (_) => ReceiveFinalPage(
                                            hiveSignerUrl: uri.toString(),
                                          )));
                            }
                          },
                          mainContent: Center(
                            child: Text(
                              'Continue',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          expandableContent: Container(),
                          expandable: false,
                        ),
                      ),
                    ]),
                    Container(
                      height: 25,
                    ),
                  ],
                ),
              );
            }
            if (state is Loading) {
              return Text('Loading');
            }
            return AskLogin();
          },
        ),
      ),
    );
  }
}
