import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:interactive_image/src/models/iconfig.dart';
import 'package:interactive_image/src/shared/icache_manager.dart';
import 'package:interactive_image/src/shared/icached_image.dart';
import 'movable_stack_item.dart';
import '../controllers/interactive_image_controller.dart';
import 'measured_size.dart';

typedef StringCallback(String value);

class InteractiveImage extends StatefulWidget {
  InteractiveImage({
    Key? key,
    required this.url,
    required this.iicontroller,
    this.interactive = false,
    this.clearcache = true,
    this.itemid = '',
    this.itemtitle = '',
    this.mypositionlabel = '',
    this.onGenerateConfig,
    this.onItemClick,
  }) : super(key: key);

  final InteractiveImageController iicontroller;
  final String url;
  final String itemid;
  final String itemtitle;
  final String mypositionlabel;
  final bool interactive;
  final bool clearcache;
  final StringCallback? onGenerateConfig;
  final StringCallback? onItemClick;

  @override
  _InteractiveImageState createState() => _InteractiveImageState();
}

class _InteractiveImageState extends State<InteractiveImage> {
  GlobalKey imageLayerKey = GlobalKey();
  List<Widget> stackItems = [];
  List<Widget> floatinActionButtons = [];
  String _selFloor = '1';
  String _itemTitle = '';
  String _locationId = '';
  IConfig? iConfig;

  double parentHeight = 800;
  double parentWidth = 600;

  double sx = 100;
  double sy = 100;
  double dx = 0;
  double dy = 0;

  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();

    widget.iicontroller.addListener(() {
      if (widget.iicontroller.locationId != '') {
        setState(() {
          print('new locationid: ${widget.iicontroller.locationId}');
          _locationId = widget.iicontroller.locationId;
          _addFloorElements();
        });
      }
    });

    _itemTitle = widget.itemtitle;
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    // TODO MANAGE offline
    //if (widget.clearcache) {
    await CustomCacheManager.instance.emptyCache();
    //}

    FileInfo? fi2 =
        await CustomCacheManager.instance.getFileFromCache(widget.url);
    if (fi2 == null) {
      try {
        await CustomCacheManager.instance.downloadFile(widget.url);
        var file = await CustomCacheManager.instance.getSingleFile(widget.url);
        iConfig = iConfigFromJson(file.readAsStringSync());
        _addItemIds();
        setState(() {
          _addFloorButtons();
          //_addFloorElements(); **M
        });
      } catch (e) {
        _addErrorElement('No internet connection');
      }
    }
  }

  void _addErrorElement(String text) {
    stackItems.clear();
    setState(() {
      stackItems.add(
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(text),
              SizedBox(
                height: 10.0,
              ),
              Icon(Icons.error),
            ],
          ),
        ),
      );
    });
  }

  void _addItemIds() {
    widget.iicontroller.locationList.clear();
    iConfig!.floors.forEach((floor) {
      floor.items.forEach((msitem) {
        widget.iicontroller.locationList.add(msitem.id);
      });
    });
    //widget.iicontroller.loctionList
  }

  _getStackItems() {
    //var a = iConfig!.floors[_getFloorIndexFromId(_selFloor)];
    stackItems.clear();
    _calculateSizeAndPosition();
    print('*********** !!!!!!!! Get Stack Items');
    _addImageItem();
    _addMovableStackItems();
    return stackItems;
  }

  void _addFloorElements() {
    /* stackItems.clear();
    print("_addFloorElements ${stackItems.length}");
    setState(() {
      _addImageItem();
      _addMovableStackItems();
    });*/
  }

  void _addImageItem() {
    if (iConfig != null) {
      var a = iConfig!.floors[_getFloorIndexFromId(_selFloor)];
      print('****** _addImageItem');
      stackItems.add(FittedBox(
        child: MeasuredSize(
          onChange: (size) {
            print('MeasuredSize size ${size.width}');
          },
          child: IcachedImage(
            key: imageLayerKey,
            imageurl: a.imageurl,
          ),
        ),
      ));
    }
    /*stackItems.add(Positioned(
      width: 200,
      height: 300,
      top: 10,
      left: 10,
      child: Container(
        color: Colors.black45,
      ),
    ));*/
  }

  void _addMovableStackItems() {
    int i = 0;
    iConfig!.floors[_getFloorIndexFromId(_selFloor)].items.forEach((msitem) {
      // If not in edit mode add only the itemid passed as parameter
      i++;
      // TODO: ADD also the myposition, if available...
      print("$i ${widget.interactive} ${msitem.id} ${widget.itemid}");

      if (widget.interactive == true) {
        stackItems.add(MoveableStackItem(
          msitem: msitem,
          sy: sy,
          sx: sx,
          dy: dy,
          dx: dx,
          interactive: true,
          onItemSelect: (String id) {
            setState(() {
              _itemTitle = 'Selected item id: $id';
            });
            if (widget.onItemClick != null) {
              widget.onItemClick!(id);
            } else {
              print(_itemTitle);
            }
          },
        ));
      }

      if (widget.interactive == false && msitem.id == widget.itemid) {
        stackItems.add(MoveableStackItem(
          msitem: msitem,
          sx: sx,
          sy: sy,
          dx: dx,
          dy: dy,
          interactive: false,
          iconname: 'circle', // Override the icon name
          iconcolor: '#FF0000',
          onItemSelect: (String id) {
            /*setState(() {
              _itemTitle = 'Selected item id: $id';
            });*/
          },
        ));
      }

      if (widget.interactive == false && msitem.id == _locationId) {
        stackItems.add(MoveableStackItem(
          msitem: msitem,
          sx: sx,
          sy: sy,
          dx: dx,
          dy: dy,

          interactive: false,
          pulse: true,
          iconname: 'my_location', // Override the icon name
          iconcolor: '#0000FF',
          onItemSelect: (String id) {
            /*setState(() {
              _itemTitle = 'Selected item id: $id';
            });*/
          },
        ));
      }
    });
  }

  void _addFloorButtons() {
    floatinActionButtons.clear();
    iConfig!.floors.forEach((floor) {
      floatinActionButtons.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton(
            backgroundColor:
                (_selFloor == floor.id) ? Colors.orange : Colors.blue,
            child: Text(floor.id),
            mini: false,
            onPressed: () {
              _changeFloor(floor.id);
            },
          ),
        ),
      );
    });

    if (widget.interactive) {
      // Add a + for adding points
      floatinActionButtons.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton(
            backgroundColor: Colors.red,
            child: Icon(Icons.plus_one),
            mini: false,
            onPressed: () {
              _addNewMSItem();
            },
          ),
        ),
      );

      // Add a export for generating JSON
      floatinActionButtons.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton(
            backgroundColor: Colors.red,
            child: Icon(Icons.download),
            mini: false,
            onPressed: () {
              _generateJSonConfig();
            },
          ),
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
          latLng: [0.0, 0.0],
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

      //_addFloorElements();
      _addFloorButtons();
    });
  }

  void _calculateSizeAndPosition() {
    //final Size? box = imageLayerKey.currentContext?.size;

    final Size box = Size(1984, 1160);

    if (box != null) {
      print("$parentWidth-$parentHeight ${box.width}-${box.height}; ");

      var arx = box.width;
      var ary = box.height;

      var acx = parentWidth;
      var acy = parentHeight;

      dx = 0.0;
      dy = 0.0;

      sy = 0.0;
      sx = 0.0;

      if ((arx / ary) < (acx / acy)) {
        dy = 0.0;
        sy = acy;
        sx = arx / ary * acy;
        dx = (acx - sx).abs() / 2;
      } else {
        dx = 0.0;
        sx = acx;
        sy = ary / arx * acx;
        dy = (acy - sy).abs() / 2;
      }

      print('sx: $sx, sy: $sy, dx: $dx, dy: $dy');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_locationId != '' || _itemTitle != '')
          Container(
            //height: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_locationId != '')
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Icon(Icons.my_location),
                        SizedBox(width: 10),
                        Text(widget.mypositionlabel + _locationId),
                      ],
                    ),
                  ),
                if (_itemTitle != '')
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Icon(Icons.pin_drop),
                        SizedBox(width: 10),
                        Text(_itemTitle),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        Expanded(
          child: Container(
            color: Colors.red,
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
                    print(
                        'on interaction start ${_transformationController.value}');
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
                  child: LayoutBuilder(builder: (ctx, constraints) {
                    if (parentHeight != constraints.maxHeight) {
                      parentHeight = constraints.maxHeight;
                      parentWidth = constraints.maxWidth;
                      _calculateSizeAndPosition();
                    }

                    print('Max height:  $parentHeight Max width: $parentWidth');
                    return Stack(
                      fit: StackFit.expand,
                      //children: stackItems,
                      children: _getStackItems(),
                    );
                  }),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Column(
                    children: floatinActionButtons,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
