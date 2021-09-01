import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:interactive_image/interactive_image.dart';

void main() {
  runApp(MyApp());
}

Future<File> writeStringToFile(String value) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/configuration.json');
  return file.writeAsString(value);
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
          interactive: true,
          url:
              'https://raw.githubusercontent.com/dariocavada/interactive_image/master/data/configuration.json',
          onGenerateConfig: (value) async {
            print("value: $value");
            File file = await writeStringToFile(value);

            print("path: ${file.path}");

            Share.shareFiles([file.path],
                text: 'Interactive Image Configuration.json');
          },
        ),
      ),
    );
  }
}
