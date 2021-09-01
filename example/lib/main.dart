import 'package:flutter/material.dart';
import 'package:interactive_image/interactive_image.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Image Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Interactive Image Demo'),
        ),
        body: InteractiveImage(
          url:
              'https://raw.githubusercontent.com/dariocavada/interactive_image/master/data/configuration.json',
        ),
      ),
    );
  }
}
