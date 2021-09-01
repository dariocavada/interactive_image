import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:interactive_image/src/models/iconfig.dart';
import 'package:interactive_image/src/shared/icache_manager.dart';
import 'package:interactive_image/src/shared/icached_image.dart';
import 'movable_stack_item.dart';
import '../controllers/interactive_image_controller.dart';

typedef StringCallback(String value);

class InteractiveImage extends StatefulWidget {
  InteractiveImage({
    Key? key,
    required this.url,
    this.interactive = false,
    this.onGenerateConfig,
  }) : super(key: key);

  final String url;
  final bool interactive;
  final StringCallback? onGenerateConfig;

  @override
  _InteractiveImageState createState() => _InteractiveImageState();
}

class _InteractiveImageState extends State<InteractiveImage> {
  List<Widget> stackItems = [];
  List<FloatingActionButton> floatinActionButtons = [];
  String _selFloor = '1';
  IConfig? iConfig;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    /*stackItems.add(
      SGWidget(
        url:
            "https://s3-eu-west-1.amazonaws.com/mkspresprod.suggesto.eu/mdgcaritro/mappe/mcf/mcf-0.jpg",
        floor: "T",
      ),
    );*/
    //_asyncInitializer();
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _asyncInitializer();
    });
  }

  int _getFloorIndexFromId(String id) {
    final index = iConfig!.floors.indexWhere((element) => element.id == id);
    if (index < 0) {
      return 0;
    } else {
      return index;
    }
  }

  void _asyncInitializer() async {
    // TODO MANAGE NETWORK ERRORS
    await CustomCacheManager.instance.emptyCache();
    FileInfo? fi2 =
        await CustomCacheManager.instance.getFileFromCache(widget.url);
    if (fi2 == null) {
      await CustomCacheManager.instance.downloadFile(widget.url);
    }
    var file = await CustomCacheManager.instance.getSingleFile(widget.url);
    iConfig = iConfigFromJson(file.readAsStringSync());
    setState(() {
      _addFloorButtons();
      _addFloorElements();
    });
  }

  void _addFloorElements() {
    stackItems.clear();
    print("_addFloorElements ${stackItems.length}");
    setState(() {
      _addImageItem();
      _addMovableStackItems();
    });
  }

  void _addImageItem() {
    var a = iConfig!.floors[_getFloorIndexFromId(_selFloor)];
    stackItems.add(
      IcachedImage(
        key: Key('imagemap'),
        imageurl: a.imageurl,
      ),
    );
  }

  void _addMovableStackItems() {
    iConfig!.floors[_getFloorIndexFromId(_selFloor)].items.forEach((msitem) {
      stackItems.add(MoveableStackItem(
        msitem: msitem,
        interactive: true,
      ));
    });
  }

  void _addFloorButtons() {
    floatinActionButtons.clear();
    iConfig!.floors.forEach((floor) {
      floatinActionButtons.add(
        FloatingActionButton(
          backgroundColor:
              (_selFloor == floor.id) ? Colors.orange : Colors.blue,
          child: Text(floor.id),
          onPressed: () {
            _changeFloor(floor.id);
          },
        ),
      );
    });

    if (widget.interactive) {
      // Add a + for adding points
      floatinActionButtons.add(
        FloatingActionButton(
          backgroundColor: Colors.red,
          child: Icon(Icons.plus_one),
          onPressed: () {
            _addNewMSItem();
          },
        ),
      );

      // Add a export for generating JSON
      floatinActionButtons.add(
        FloatingActionButton(
          backgroundColor: Colors.red,
          child: Icon(Icons.download),
          onPressed: () {
            _generateJSonConfig();
          },
        ),
      );
    }
  }

  void _addNewMSItem() {
    setState(() {
      MSItem msitem = MSItem(
          id: '999',
          number: 'number',
          title: 'title',
          subtitle: 'subtitle',
          description: 'description',
          type: 'type',
          xPosition: 0.0,
          yPosition: 0.0,
          width: 10,
          height: 10,
          fillcolor: 'fillcolor',
          bordercolor: 'bordercolor',
          iconName: 'iconName');

      iConfig?.floors[_getFloorIndexFromId(_selFloor)].items.add(msitem);

      _addFloorElements();
    });
  }

  void _generateJSonConfig() {
    stackItems.forEach((element) {
      print(element.runtimeType);
    });

    if (widget.onGenerateConfig != null) {
      widget.onGenerateConfig!(iConfigToJson(iConfig!));
    } else {
      print("Config");
      print(iConfigToJson(iConfig!));
      print("...");
    }
  }

  void _changeFloor(String id) {
    setState(() {
      print('$_changeFloor $id');
      _selFloor = id;
      _addFloorElements();
      _addFloorButtons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            //alignPanAxis: true,
            //boundaryMargin: EdgeInsets.all(double.infinity),
            transformationController: _transformationController,
            minScale: 0.1,
            maxScale: 3.0,
            constrained: true,
            onInteractionStart: (_) {
              print('Interaction Start');
              print('on interaction start ${_transformationController.value}');
            },
            onInteractionEnd: (details) {
              print('on interaction end');
              setState(() {
                //_transformationController.value = Matrix4.identity();
                //_transformationController.toScene(Offset.zero);
                print('${_transformationController.value}');
              });
            },
            //onInteractionUpdate: (_) => print('Interaction Updated'),
            child: Stack(
              fit: StackFit.expand,
              children: stackItems,
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: ButtonBar(
              children: floatinActionButtons,
            ),
          ),
        ],
      ),
    );
  }
}

class SGWidget extends StatelessWidget {
  const SGWidget({
    Key? key,
    required this.url,
    required this.floor,
  }) : super(key: key);

  final String url;
  final String floor;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: NetworkImage(url),
    );
  }
}
