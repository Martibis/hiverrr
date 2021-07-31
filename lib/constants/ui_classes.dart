import 'package:flutter/material.dart';

class MyEdgeInsets {
  final EdgeInsets standardAll = EdgeInsets.all(25);
  final EdgeInsets leftRight = EdgeInsets.fromLTRB(25, 0, 25, 0);
  final EdgeInsets bottomLeftRight = EdgeInsets.fromLTRB(25, 0, 25, 25);
}

class MyColors {
  final Color black90 = Colors.black.withOpacity(0.9);
  final Color lightGrey = Color.fromARGB(255, 230, 230, 230);
  final Color darkGrey = Color.fromARGB(255, 145, 145, 145);
  //final Color mainColor = Color.fromARGB(255, 252, 85, 85);
  final Color mainAccentColor = Colors.white;
  final Color mainColor = Color.fromRGBO(252, 85, 85, 1);
}

class MyBoxShadows {
  List<BoxShadow> lightShadow = [
    BoxShadow(
        color: Colors.grey.shade500,
        offset: Offset(4.0, 4.0),
        blurRadius: 7.0,
        spreadRadius: 1.0),
    BoxShadow(
        color: Colors.white,
        offset: Offset(-4.0, -4.0),
        blurRadius: 7.0,
        spreadRadius: 1.0),
  ];
  /*  [
    BoxShadow(
        color: Color.fromRGBO(255, 255, 255, 0.8),
        blurRadius: 7,
        offset: Offset(0, -4)),
    BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.2),
        blurRadius: 7,
        offset: Offset(0, 4))
  ]; */
  List<BoxShadow> darkShadow = [
    BoxShadow(
        color: Color.fromRGBO(255, 255, 255, 0.15),
        blurRadius: 7,
        offset: Offset(4, 4),
        spreadRadius: 1),
    BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 1),
        blurRadius: 7,
        offset: Offset(-4, -4),
        spreadRadius: 1)
  ];
}

class ThemeDatas {
  final ThemeData lightTheme = ThemeData(
    //backgroundColor: Colors.grey[300],
    //scaffoldBackgroundColor: Colors.grey[300],
    backgroundColor: Color.fromRGBO(230, 230, 230, 1),
    scaffoldBackgroundColor: Color.fromRGBO(230, 230, 230, 1),
    primaryColor: Color.fromRGBO(230, 230, 230, 1),
    accentColor: Color.fromRGBO(227, 19, 55, 1),
    highlightColor: Color.fromRGBO(40, 164, 67, 1),
    fontFamily: 'Quicksand',
    dividerColor: Colors.black,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.black, //thereby
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      fillColor: Colors.white,
      filled: true,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10.0),
      ),
      border: UnderlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10.0),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusColor: Colors.white,
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10.0),
      ),
      disabledBorder: UnderlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10.0),
      ),
      hoverColor: Colors.white,
    ),
  );
  final ThemeData darkTheme = ThemeData(
    backgroundColor: Color.fromRGBO(37, 37, 37, 1),
    scaffoldBackgroundColor: Color.fromRGBO(37, 37, 37, 1),
    primaryColor: Color.fromRGBO(37, 37, 37, 1),
    accentColor: Color.fromRGBO(227, 19, 55, 1),
    highlightColor: Color.fromRGBO(86, 255, 123, 1),
    fontFamily: 'Quicksand',
    textTheme: TextTheme(
      bodyText1: TextStyle(),
      bodyText2: TextStyle(),
    ).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    dividerColor: Colors.white,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.black, //thereby
    ),
    inputDecorationTheme: InputDecorationTheme(
      helperStyle: TextStyle(color: Colors.white),
      contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      fillColor: Colors.white,
      filled: true,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10.0),
      ),
      border: UnderlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10.0),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusColor: Colors.white,
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10.0),
      ),
      disabledBorder: UnderlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10.0),
      ),
      hoverColor: Colors.white,
    ),
  );
}
