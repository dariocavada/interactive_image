import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
//import 'package:share_plus/share_plus.dart';
import 'package:interactive_image/interactive_image.dart';

// import 'package:flutter/rendering.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:path_provider/path_provider.dart';

InteractiveImageController interactiveImageController =
    InteractiveImageController();

/*
          /* url:
              'https://raw.githubusercontent.com/dariocavada/interactive_image/master/data/configuration.json',*/
          /*url:
              'https://s3-eu-west-1.amazonaws.com/mkspresprod.suggesto.eu/mdgcaritro/mappe/demo/configuration.json',*/
          /*url:
              'https://s3-eu-west-1.amazonaws.com/mkspresprod.suggesto.eu/mdgcaritro/mappe/mcf/configuration.json',*/

*/

String _itemid = '';
String globalurl =
    'https://s3-eu-west-1.amazonaws.com/mkspresprod.suggesto.eu/mdgcaritro/mappe/mdg/configuration.json';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Image Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class ConfigStorage {
  Future<String> get _localPath async {
    final directory = await getDownloadsDirectory();

    return directory?.path ?? '.';
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      return File('$path/interactiveimageconfig.json');
    } else {
      return File('$selectedDirectory/interactiveimageconfig.json');
    }
  }

  Future<String> readConfig() async {
    try {
      final file = await _localFile;
      final content = await file.readAsString();
      return content;
    } catch (e) {
      // If encountering an error, return 0
      return '';
    }
  }

  Future<File> writeConfig(String config) async {
    final file = await _localFile;
    return file.writeAsString(config);
  }
}

class HomeScreen extends StatefulWidget {
  final ConfigStorage storage = ConfigStorage();

  HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Image Edit'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            tooltip: 'Go to test page',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return TestScreen(
                    itemid: _itemid,
                  );
                }),
              );
            },
          ), //IconButton
          //IconButton
        ],
      ),
      body: InteractiveImageMap(
          clearcache: false,
          interactive: true,
          //toolbarPosition: ToolbarPosition.top,
          toolbarPosition: ToolbarPosition.right,
          iicontroller: interactiveImageController,
          openstreetmap: false,
          // Selected item id to show on the map (filtered only if interactive: false)
          // itemid: '1',
          // If we have a translation of the item, otherwise take the item title value
          itemtitle: 'Name of the poi',
          // Shown only if the controller is attached and the positionid is set
          mypositionlabel: 'Posizione',
          url: globalurl,
          onGenerateConfig: (value) async {
            widget.storage.writeConfig(value);
          },
          onAddNewItem: (value) {
            // set new values in the controller and set a notification for adding a value
            print('onAddNewItem: $value');
          },
          onItemClick: (value) async {
            print('onItemClick: $value');

            /* Global item id */
            _itemid = value.id;

            interactiveImageController.msitem.id = value.id; //
            interactiveImageController.msitem.number = value.number; //
            interactiveImageController.msitem.title = value.title; //
            interactiveImageController.msitem.subtitle = value.subtitle; //
            interactiveImageController.msitem.description = value.description;
            interactiveImageController.msitem.type = value.type; // beacon
            interactiveImageController.msitem.latLng = value.latLng; // -->
            interactiveImageController.msitem.width = value.width;
            interactiveImageController.msitem.height = value.height;
            interactiveImageController.msitem.fillcolor = value.fillcolor;
            interactiveImageController.msitem.bordercolor = value.bordercolor;
            interactiveImageController.msitem.iconName = value.iconName;

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FormScreen()),
            );
            //interactiveImageController.setLocationId("");
          }),
    );
  }
}

class TestScreen extends StatefulWidget {
  // In the constructor, require a Todo.
  const TestScreen({Key? key, required this.itemid}) : super(key: key);

  // Declare a field that holds the Todo.
  final String itemid;

  @override
  TestScreenState createState() => TestScreenState();
}

class TestScreenState extends State<TestScreen> {
  final InteractiveImageController interactiveImageController =
      InteractiveImageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test'),
        actions: [
          Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.white),
              textTheme: const TextTheme().apply(bodyColor: Colors.white),
            ),
            child: PopupMenuButton<int>(
                color: Colors.orange,
                onSelected: (item) {
                  if (item < 99) {
                    interactiveImageController.setLocationId('00$item');
                  } else {
                    interactiveImageController.setLocationId('$item');
                  }
                },
                itemBuilder: (context) {
                  return List.generate(
                      interactiveImageController.locationList.length, (index) {
                    return PopupMenuItem(
                      value: int.parse(
                        interactiveImageController.locationList[index],
                      ),
                      child: Text(
                          'Item: ${interactiveImageController.locationList[index]}'),
                    );
                  });
                }),
          ),
        ],
      ),
      body: InteractiveImageMap(
        clearcache: false,
        interactive: false,
        iicontroller: interactiveImageController,
        itemid: widget.itemid,
        url: globalurl,
      ),
    );
  }
}

class FormScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormBuilderState>();

  FormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: () {
              Navigator.pop(context);
              interactiveImageController.setChangeId('test');
            },
          ),

          //IconButton
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            FormBuilder(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  FormBuilderTextField(
                    name: 'id',
                    initialValue: interactiveImageController.msitem.id,
                    decoration: const InputDecoration(
                      labelText: 'id',
                    ),
                    onChanged: (value) => {
                      interactiveImageController.msitem.id = value!,
                    },
                  ),
                  FormBuilderTextField(
                    name: 'number',
                    initialValue: interactiveImageController.msitem.number,
                    decoration: const InputDecoration(
                      labelText: 'number',
                    ),
                    onChanged: (value) => {
                      interactiveImageController.msitem.number = value!,
                    },
                  ),
                  FormBuilderTextField(
                    name: 'title',
                    initialValue: interactiveImageController.msitem.title,
                    decoration: const InputDecoration(
                      labelText: 'title',
                    ),
                    onChanged: (value) => {
                      interactiveImageController.msitem.title = value!,
                    },
                  ),
                  FormBuilderTextField(
                    name: 'subtitle',
                    initialValue: interactiveImageController.msitem.subtitle,
                    decoration: const InputDecoration(
                      labelText: 'subtitle',
                    ),
                    onChanged: (value) => {
                      interactiveImageController.msitem.subtitle = value!,
                    },
                  ),
                  FormBuilderTextField(
                    name: 'description',
                    initialValue: interactiveImageController.msitem.description,
                    decoration: const InputDecoration(
                      labelText: 'description',
                    ),
                    onChanged: (value) => {
                      interactiveImageController.msitem.description = value!,
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
