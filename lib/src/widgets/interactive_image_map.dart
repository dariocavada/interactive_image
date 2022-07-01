import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:interactive_image/src/models/iconfig.dart';
import 'package:interactive_image/src/shared/icache_manager.dart';
//import 'package:interactive_image/src/shared/icached_image.dart';
//import 'movable_stack_item.dart';
import '../controllers/interactive_image_controller.dart';
//import 'measured_size.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/dragmarker.dart';
import 'package:latlong2/latlong.dart';

typedef IIMStringCallback(String value);
typedef IIMSItemCallback(MSItem value);

class ToolbarPosition {
  static const left = 0;
  static const top = 1;
  static const bottom = 2;
  static const right = 3;
}

class InteractiveImageMap extends StatefulWidget {
  InteractiveImageMap(
      {Key? key,
      required this.url,
      required this.iicontroller,
      this.interactive = false,
      this.openstreetmap = false,
      this.clearcache = true,
      this.itemid = '',
      this.itemtitle = '',
      this.mypositionlabel = '',
      this.onGenerateConfig,
      this.onAddNewItem,
      this.onItemClick,
      this.toolbarPosition = ToolbarPosition.right})
      : super(key: key);

  final InteractiveImageController iicontroller;
  final String url;
  final String itemid;
  final String itemtitle;
  final String mypositionlabel;
  final bool interactive;
  final bool openstreetmap;
  final bool clearcache;
  final int toolbarPosition;
  final IIMStringCallback? onGenerateConfig;
  final IIMStringCallback? onAddNewItem;
  final IIMSItemCallback? onItemClick;

  @override
  _InteractiveImageMapState createState() => _InteractiveImageMapState();
}

class _InteractiveImageMapState extends State<InteractiveImageMap>
    with TickerProviderStateMixin {
  late final MapController mapController;
  List<OverlayImage> overlayImages = [];
  List<Widget> floatinActionButtons = [];

  LatLngBounds _curBounds = LatLngBounds(
    LatLng(46.29177547878278, 11.458737395300826),
    LatLng(46.29157855872656, 11.459258968986305),
  );

  String _selFloor = '0';
  String _itemTitle = '';
  String _locationId = '';
  String _locationDescription = '';
  String _mapTitle = '';
  IConfig? iConfig;

  @override
  void initState() {
    super.initState();

    mapController = MapController();

    widget.iicontroller.addListener(_iicListener);

    _itemTitle = widget.itemtitle;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncInitializer();
    });
  }

  void _iicListener() {
    print(
        'InteractiveImageMap receive notification ${widget.iicontroller.locationId}');

    if (widget.interactive == true) {
      if (iConfig != null) {
        iConfig!.floors.forEach((floor) {
          floor.items.forEach((msitem) {
            // Your Location

            if (msitem.id == widget.iicontroller.msitem.id) {
              print(
                  'InteractiveImageMap modify with ${widget.iicontroller.msitem.title}');
              setState(() {
                msitem.id = widget.iicontroller.msitem.id;
                msitem.number = widget.iicontroller.msitem.number;
                msitem.title = widget.iicontroller.msitem.title;
                msitem.subtitle = widget.iicontroller.msitem.subtitle;
                msitem.description = widget.iicontroller.msitem.description;
              });
              // change content of msitem
            }
          });
        });
      }
    }

    if (widget.iicontroller.locationId != '') {
      setState(() {
        print(
            'InteractiveImageMap new locationid: ${widget.iicontroller.locationId}');
        _locationId = widget.iicontroller.locationId;
        //_locationDescription = _locationId + 'inserirlo qui ?';

        if (iConfig != null) {
          iConfig!.floors.forEach((floor) {
            floor.items.forEach((msitem) {
              // Your Location
              print(
                  'InteractiveImageMap forEach ${msitem.number} == ${widget.iicontroller.locationId}');
              if (widget.interactive == false &&
                  msitem.number == widget.iicontroller.locationId) {
                _locationDescription =
                    '${msitem.title}) ${msitem.subtitle} (${floor.label})';
              }
            });
          });
        }

        //_getPosAndDestinationMarkers();
      });
    }
  }

  @override
  void dispose() {
    widget.iicontroller.removeListener(_iicListener);
    super.dispose();
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
        String itemFloor = _addItemIds(widget.itemid);

        _changeFloor(itemFloor);
      } catch (e) {
        _addErrorElement('No internet connection ${e.toString()}');
      }
    }
  }

  void _addErrorElement(String text) {
    print('MANAGE _addErrorElement ELEMENT $text');
    /*stackItems.clear();
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
    });*/
  }

  String _addItemIds(String itemId) {
    widget.iicontroller.locationList.clear();
    String itemFloor = '';
    iConfig!.floors.forEach((floor) {
      floor.items.forEach((msitem) {
        widget.iicontroller.locationList.add(msitem.id);
        if (itemId == msitem.number) {
          itemFloor = floor.id;
          print('$itemId - ${msitem.number} - ${floor.id}');
        }
      });
    });
    return itemFloor;
    //widget.iicontroller.loctionList
  }

  List<CircleMarker> _getCircles() {
    if (widget.interactive) {
      return [];
    } else {
      return _getPosAndDestinationCircles();
    }
  }

  List<Marker> _getMarkers() {
    if (widget.interactive) {
      return _getAllMarkers();
      //return _getDraggableMarkers();
    } else {
      return [];
    }
  }

  List<DragMarker> _getDraggableMarkers() {
    if (widget.interactive) {
      return _getAllDraggableMarkers();
      //return _getDraggableMarkers();
    } else {
      return [];
    }
  }

  List<Marker> _getAllMarkers() {
    print('========>>>> _getAllMarkers');
    int i = 0;
    List<Marker> cm = [];
    if (iConfig != null) {
      iConfig!.floors[_getFloorIndexFromId(_selFloor)].items.forEach((msitem) {
        // If not in edit mode add only the itemid passed as parameter
        i++;
        print("$i ${widget.interactive} ${msitem.id} ${widget.itemid}");
        print('========>>>> ${msitem.latLng[0]}, ${msitem.latLng[1]}');
        cm.add(
          Marker(
            width: 32.0,
            height: 32.0,
            point: LatLng(msitem.latLng[0], msitem.latLng[1]),
            builder: (ctx) => Container(
              child: GestureDetector(
                  onTap: () {
                    String msg =
                        'Marker: ${msitem.id} - ${msitem.number} - ${msitem.title}: ${msitem.subtitle}';
                    if (widget.onItemClick != null) {
                      widget.onItemClick!(msitem);
                      print(msitem.id);
                      setState(() {
                        _itemTitle = msg;
                      });
                    } else {
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text(msg),
                      ));
                    }
                  },
                  child: Icon(Icons.circle_rounded)),
            ),
          ),
        );
      });
    }
    return cm;
  }

  List<DragMarker> _getAllDraggableMarkers() {
    print('========>>>> _getDraggableMarkers');
    int i = 0;
    List<DragMarker> cm = [];
    if (iConfig != null) {
      iConfig!.floors[_getFloorIndexFromId(_selFloor)].items.forEach((msitem) {
        // If not in edit mode add only the itemid passed as parameter
        i++;
        print("$i ${widget.interactive} ${msitem.id} ${widget.itemid}");
        print('========>>>> ${msitem.latLng[0]}, ${msitem.latLng[1]}');
        cm.add(
          DragMarker(
            width: 32.0,
            height: 32.0,
            point: LatLng(msitem.latLng[0], msitem.latLng[1]),
            onDragStart: (details, point) => print("Start point $point"),
            onDragEnd: (details, point) {
              print("End point $point");
              msitem.latLng[0] = point.latitude;
              msitem.latLng[1] = point.longitude;
            },
            onDragUpdate: (details, point) {},
            onTap: (point) {
              String msg =
                  'Marker: ${msitem.id} - ${msitem.number} - ${msitem.title}: ${msitem.subtitle}';

              if (widget.onItemClick != null) {
                widget.onItemClick!(msitem);
                print(msitem.id);
                setState(() {
                  _itemTitle = msg;
                });
              } else {
                /*ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text(msg),
                ));*/
              }
            },
            onLongPress: (point) {
              print("on long press");
            },
            builder: (ctx) => Container(
              child: Icon(Icons.circle_rounded),
            ),
          ),
        );
      });
    }
    return cm;
  }

  List<CircleMarker> _getPosAndDestinationCircles() {
    print('========>>>> _getPosAndDestinationMarkers ${widget.itemid}');
    int i = 0;
    List<CircleMarker> cm = [];
    if (iConfig != null) {
      iConfig!.floors[_getFloorIndexFromId(_selFloor)].items.forEach((msitem) {
        // If not in edit mode add only the itemid passed as parameter
        i++;

        // POI
        if (widget.interactive == false && msitem.number == widget.itemid) {
          print("$i ${widget.interactive} ${msitem.id} ${widget.itemid}");
          print('========>>>> POI ${msitem.latLng[0]}, ${msitem.latLng[1]}');
          cm.add(CircleMarker(
              point: LatLng(msitem.latLng[0], msitem.latLng[1]),
              color: Colors.amber.withOpacity(0.6),
              borderColor: Colors.red,
              borderStrokeWidth: 4,
              useRadiusInMeter: true,
              radius: .5 // 2000 meters | 2 km
              ));
        }

        // Your Location
        if (widget.interactive == false &&
            msitem.number == widget.iicontroller.locationId) {
          _locationDescription = '${msitem.title}) ${msitem.subtitle}';

          print("$i ${widget.interactive} ${msitem.number} ${widget.itemid}");
          print(
              '========>>>> YOUR Location $_locationDescription ${msitem.latLng[0]}, ${msitem.latLng[1]}');
          cm.add(CircleMarker(
              point: LatLng(msitem.latLng[0], msitem.latLng[1]),
              color: Colors.blue.withOpacity(0.6),
              borderColor: Colors.blue,
              borderStrokeWidth: 4,
              useRadiusInMeter: true,
              radius: .5 // 2000 meters | 2 km
              ));
        }
      });
    }
    return cm;
  }

  void _addFloorButtons() {
    floatinActionButtons.clear();
    iConfig!.floors.forEach((floor) {
      if (_selFloor == floor.id) {
        _mapTitle = floor.title;
      }

      floatinActionButtons.add(
        Padding(
          padding: const EdgeInsets.all(3.0),
          child: FloatingActionButton(
            key: Key('FAB${floor.id}'),
            heroTag: null,
            backgroundColor:
                (_selFloor == floor.id) ? Colors.orange : Colors.blue,
            child: Text(floor.label),
            mini: false,
            onPressed: () {
              print(
                  "======> Check Controller location id ${widget.iicontroller.locationId}");
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
            key: Key('FABANI'),
            heroTag: null,
            backgroundColor: Colors.red,
            child: Icon(Icons.plus_one),
            mini: false,
            onPressed: () {
              _addNewMSItem(context);
            },
          ),
        ),
      );

      // Add a export for generating JSON
      floatinActionButtons.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton(
            key: Key('FABJSON'),
            heroTag: null,
            backgroundColor: Colors.red,
            child: Icon(Icons.download),
            mini: false,
            onPressed: () {
              // GenerateJSONConfig...
              _generateJSonConfig();
            },
          ),
        ),
      );
    }
  }

  String getNewId() {
    String newId = '999';
    int maxId = 0;
    iConfig?.floors[_getFloorIndexFromId(_selFloor)].items.forEach((element) {
      int iId = int.parse(element.id);
      if (iId > maxId) {
        maxId = iId;
      }
    });
    maxId++;
    if (maxId < 100) {
      newId = _getFloorIndexFromId(_selFloor).toString() +
          maxId.toString().padLeft(2, '0');
    } else {
      newId = maxId.toString().padLeft(2, '0');
    }

    return newId;
  }

  void _addNewMSItem(context) {
    if (widget.iicontroller.latitude == 0) {
      print("AlertDialog floor: ${widget.iicontroller.latitude}");
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Attenzione"),
          content: Text(
              "Clicca in un punto sulla mappa e poi clicca su +1 per aggiungere un POI. E' possibile in seguito spostare il POI trascinandolo"),
        ),
      );
    } else {
      setState(() {
        MSItem msitem = MSItem(
            id: getNewId(),
            number: '0-12345',
            title: 'title',
            subtitle: 'subtitle',
            description: 'description',
            type: 'beacon',
            latLng: [
              widget.iicontroller.latitude,
              widget.iicontroller.longitude
            ],
            width: 10,
            height: 10,
            fillcolor: 'fillcolor',
            bordercolor: 'bordercolor',
            iconName: 'iconName');

        iConfig?.floors[_getFloorIndexFromId(_selFloor)].items.add(msitem);

        if (widget.onAddNewItem != null) {
          widget.onAddNewItem!(_selFloor);
        } else {
          print("onAddNewItem floor: $_selFloor");
        }
      });
    }
  }

  void _generateJSonConfig() {
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
    });
    _addFloorButtons();
    _addImageItem();
  }

  void _addImageItem() {
    if (iConfig != null) {
      print('****** _addImageItem');
      //_getCurLatLngBounds
      double la =
          iConfig!.floors[_getFloorIndexFromId(_selFloor)].latLngBounds[0][0];
      double lb =
          iConfig!.floors[_getFloorIndexFromId(_selFloor)].latLngBounds[0][1];
      double lc =
          iConfig!.floors[_getFloorIndexFromId(_selFloor)].latLngBounds[1][0];
      double ld =
          iConfig!.floors[_getFloorIndexFromId(_selFloor)].latLngBounds[1][1];

      /*_curBounds.extendBounds(LatLngBounds(
        LatLng(la, lb),
        LatLng(lc, ld),
      ));*/

      _curBounds = LatLngBounds(
        LatLng(la, lb),
        LatLng(lc, ld),
      );

      String url = iConfig!.floors[_getFloorIndexFromId(_selFloor)].imageurl;
      print(
          'url $url $la ${_curBounds.north} $lb ${_curBounds.west} $lc ${_curBounds.south}  $ld ${_curBounds.east}');
      overlayImages.clear();
      overlayImages.add(
        OverlayImage(
          bounds: _curBounds,
          opacity: 1,
          gaplessPlayback: true,
          //imageProvider: NetworkImage(url),
          imageProvider: CachedNetworkImageProvider(url),
        ),
      );
      mapController.fitBounds(
        _curBounds,
        options: FitBoundsOptions(
          maxZoom: 24,
          padding: EdgeInsets.only(left: 0, right: 0),
        ),
      );
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
                        Icon(
                          Icons.circle_outlined,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.mypositionlabel + _locationDescription,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        /*FloatingActionButton(
                          key: Key('FABlocation'),
                          heroTag: null,
                          backgroundColor: Colors.blue,
                          child: Text('1'),
                          mini: true,
                          onPressed: () => {},
                        ),*/
                      ],
                    ),
                  ),
                if (_itemTitle != '')
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    /*
                    child: Text(
                      'osti+' + _itemTitle,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),*/

                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Icon(
                          Icons.circle_outlined,
                          color: Colors.red,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _itemTitle,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        Expanded(
          child: Container(
            //color: Colors.red,
            color: Colors.white,
            child: Stack(
              fit: StackFit.expand,
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    bounds: _curBounds,
                    boundsOptions: FitBoundsOptions(
                      maxZoom: 24,
                      padding: EdgeInsets.only(left: 0.0, right: 0.0),
                    ),
                    onTap: (tapPos, latLng) {
                      if (widget.interactive == true) {
                        widget.iicontroller.latitude = latLng.latitude;
                        widget.iicontroller.longitude = latLng.longitude;
                        setState(() {
                          _locationId = 'ND';
                          _locationDescription =
                              ': ${latLng.latitude}, ${latLng.longitude}';
                        });
                      }

                      print(
                          'OnTap: LatLng: ${latLng.latitude}, ${latLng.longitude}');

                      setState(() {
                        // TODO  forse da rimuovere
                        mapController.fitBounds(_curBounds,
                            options: FitBoundsOptions(
                              maxZoom: 24,
                              padding: EdgeInsets.only(left: 0, right: 0),
                            ));
                      });
                    },
                    zoom: 20.0,
                    maxZoom: 24.0,
                    minZoom: 9.0,
                    allowPanningOnScrollingParent: false,
                    plugins: [
                      DragMarkerPlugin(),
                    ],
                    interactiveFlags:
                        InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  ),
                  layers: [
                    if (widget.openstreetmap)
                      TileLayerOptions(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: ['a', 'b', 'c'],
                        maxZoom: 30,
                        maxNativeZoom: 30,
                      ),
                    OverlayImageLayerOptions(overlayImages: overlayImages),
                    CircleLayerOptions(circles: _getCircles()),
                    DragMarkerPluginOptions(markers: _getDraggableMarkers()),
                    //MarkerLayerOptions(markers: _getMarkers()),
                  ],
                ),
                if (widget.toolbarPosition == ToolbarPosition.right)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Column(
                      children: floatinActionButtons,
                    ),
                  ),
                if (widget.toolbarPosition == ToolbarPosition.top)
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Row(
                      children: floatinActionButtons,
                    ),
                  )
              ],
            ),
          ),
        ),
        if (_mapTitle != '')
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _mapTitle,
                maxLines: 2,
                overflow: TextOverflow.fade,
              ),
            ),
          )
      ],
    );
  }
}
