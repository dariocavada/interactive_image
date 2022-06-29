import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
//import 'package:share_plus/share_plus.dart';
import 'package:interactive_image/interactive_image.dart';

// import 'package:flutter/rendering.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:path_provider/path_provider.dart';

InteractiveImageController interactiveImageController =
    new InteractiveImageController();

void main() {
  /*debugPaintSizeEnabled = true;
  debugPaintBaselinesEnabled = false;
  debugPaintLayerBordersEnabled = false;
  debugPaintPointersEnabled = true;
  debugRepaintRainbowEnabled = false;
  debugRepaintTextRainbowEnabled = false;
  debugCheckElevationsEnabled = false;
  debugDisableClipLayers = false;
  debugDisablePhysicalShapeLayers = true;
  debugDisableOpacityLayers = true;*/
  runApp(MyApp());
}

/* Future<File> writeStringToFile(String value) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/configuration.json');
  return file.writeAsString(value);
}*/

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Image Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
      //home: AnimatedMapControllerPage(),
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
      print('$path/interactiveimageconfig.json');
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

    // Write the file
    return file.writeAsString(config);
  }
}

class HomeScreen extends StatefulWidget {
  final ConfigStorage storage = new ConfigStorage();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _itemid = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*bottomSheet: Container(
        color: Colors.yellow,
        alignment: Alignment.center,
        height: 100,
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        child: Text(
          'USe Image size for markers ! https://stackoverflow.com/questions/49307677/how-to-get-height-of-a-widget',
          maxLines: 10,
          overflow: TextOverflow.ellipsis,
        ),
      ),*/
      appBar: AppBar(
        title: Text('Interactive Image: Edit mode'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_forward),
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
          toolbarPosition: ToolbarPosition.top,
          iicontroller: interactiveImageController,
          openstreetmap: false,
          // Selected item id to show on the map (filtered only if interactive: false)
          // itemid: '1',
          // If we have a translation of the item, otherwise take the item title value
          itemtitle: 'Name of the poi',
          // Shown only if the controller is attached and the positionid is set
          mypositionlabel: 'La tua posizione',
          /* url:
              'https://raw.githubusercontent.com/dariocavada/interactive_image/master/data/configuration.json',*/
          /*url:
              'https://s3-eu-west-1.amazonaws.com/mkspresprod.suggesto.eu/mdgcaritro/mappe/demo/configuration.json',*/
          /*url:
              'https://s3-eu-west-1.amazonaws.com/mkspresprod.suggesto.eu/mdgcaritro/mappe/mcf/configuration.json',*/
          /*url:
              'https://s3-eu-west-1.amazonaws.com/mkspresprod.suggesto.eu/mdgcaritro/mappe/mdg/configuration.json',*/
          url:
              'https://s3-eu-west-1.amazonaws.com/mkspresprod.suggesto.eu/mdgcaritro/mappe/istladin/configuration.json',
          onGenerateConfig: (value) async {
            widget.storage.writeConfig(value);
          },
          onAddNewItem: (value) {
            // set new values in the controller and set a notification for adding a value
            print('onAddNewItem: $value');
          },
          onItemClick: (value) async {
            print('onItemClick: $value');

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
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final InteractiveImageController interactiveImageController =
      new InteractiveImageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interactive Image: Test'),
        actions: [
          Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.white),
              textTheme: TextTheme().apply(bodyColor: Colors.white),
            ),
            child: PopupMenuButton<int>(
                color: Colors.orange,
                onSelected: (item) =>
                    interactiveImageController.setLocationId('$item'),
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

        /* url:
              'https://raw.githubusercontent.com/dariocavada/interactive_image/master/data/configuration.json',*/
        /*url:
            'https://s3-eu-west-1.amazonaws.com/mkspresprod.suggesto.eu/mdgcaritro/mappe/mcf/configuration.json',*/
        /*url:
            'https://s3-eu-west-1.amazonaws.com/mkspresprod.suggesto.eu/mdgcaritro/mappe/mdg/configuration.json',*/
        url:
            'https://s3-eu-west-1.amazonaws.com/mkspresprod.suggesto.eu/mdgcaritro/mappe/istladin/configuration.json',
      ),
    );
  }
}

class FormScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interactive Image: Edit mode'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
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
                    decoration: InputDecoration(
                      labelText: 'id',
                    ),
                    onChanged: (value) => {
                      interactiveImageController.msitem.id = value!,
                    },
                  ),
                  FormBuilderTextField(
                    name: 'number',
                    initialValue: interactiveImageController.msitem.number,
                    decoration: InputDecoration(
                      labelText: 'number',
                    ),
                    onChanged: (value) => {
                      interactiveImageController.msitem.number = value!,
                    },
                  ),
                  FormBuilderTextField(
                    name: 'title',
                    initialValue: interactiveImageController.msitem.title,
                    decoration: InputDecoration(
                      labelText: 'title',
                    ),
                    onChanged: (value) => {
                      interactiveImageController.msitem.title = value!,
                    },
                  ),
                  FormBuilderTextField(
                    name: 'subtitle',
                    initialValue: interactiveImageController.msitem.subtitle,
                    decoration: InputDecoration(
                      labelText: 'subtitle',
                    ),
                    onChanged: (value) => {
                      interactiveImageController.msitem.subtitle = value!,
                    },
                  ),
                  FormBuilderTextField(
                    name: 'description',
                    initialValue: interactiveImageController.msitem.description,
                    decoration: InputDecoration(
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
