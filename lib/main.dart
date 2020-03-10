import 'package:flutter/material.dart';
import 'todoscreen.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final materialApp = MaterialApp(
      title: '',
      home: TodoScreen(),
    );
    return materialApp;
    
  }
}
