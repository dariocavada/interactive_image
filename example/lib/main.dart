import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:interactive_image/interactive_image.dart';

void main() {
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
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _itemid = '';
  InteractiveImageController interactiveImageController =
      new InteractiveImageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: InteractiveImage(
          clearcache: false,
          interactive: true,
          iicontroller: interactiveImageController,
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
          url:
              'https://s3-eu-west-1.amazonaws.com/mkspresprod.suggesto.eu/mdgcaritro/mappe/mcf/configuration.json',
          onGenerateConfig: (value) async {
            Share.share(value, subject: 'Interactive Image Configuration');
            /*Share.shareFiles([file.path],
              text: 'Interactive Image Configuration.json');*/
          },
          onItemClick: (value) {
            _itemid = value;
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
      body: InteractiveImage(
        clearcache: false,
        interactive: false,
        iicontroller: interactiveImageController,
        itemid: widget.itemid,

        /* url:
              'https://raw.githubusercontent.com/dariocavada/interactive_image/master/data/configuration.json',*/
        url:
            'https://s3-eu-west-1.amazonaws.com/mkspresprod.suggesto.eu/mdgcaritro/mappe/mcf/configuration.json',
      ),
    );
  }
}
