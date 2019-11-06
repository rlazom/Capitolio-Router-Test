import 'package:flutter/material.dart';

import 'package:capitol_routers/views/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var title = 'Flutter Capitolio Test';

    return MaterialApp(
      title: title,
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: title),
    );
  }
}
