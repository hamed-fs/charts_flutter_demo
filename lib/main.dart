import 'package:flutter/material.dart';

import 'package:charts_flutter_demo/simple.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Charts Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Charts Flutter Demo'),),
        body: SimpleLineChart(),
      ),
    );
  }
}
