import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:interactive_image/src/models/iconfig.dart';
import 'package:interactive_image/src/shared/icache_manager.dart';
//import 'package:interactive_image/src/shared/icached_image.dart';
//import 'movable_stack_item.dart';
import '../controllers/interactive_image_controller.dart';
//import 'measured_size.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

typedef IIMStringCallback(String value);

class InteractiveImageMap extends StatefulWidget {
  InteractiveImageMap({
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
  final IIMStringCallback? onGenerateConfig;
  final IIMStringCallback? onItemClick;

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
  IConfig? iConfig;

  @override
  void initState() {
    super.initState();

    mapController = MapController();

    widget.iicontroller.addListener(() {
      if (widget.iicontroller.locationId != '') {
        setState(() {
          print('new locationid: ${widget.iicontroller.locationId}');
          _locationId = widget.iicontroller.locationId;
        });
      }
    });

    _itemTitle = widget.itemtitle;
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
        _changeFloor('0');
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

  void _addItemIds() {
    widget.iicontroller.locationList.clear();
    iConfig!.floors.forEach((floor) {
      floor.items.forEach((msitem) {
        widget.iicontroller.locationList.add(msitem.id);
      });
    });
    //widget.iicontroller.loctionList
  }

  List<CircleMarker> _getMarkers() {
    if (widget.interactive) {
      return _getAllMarkers();
    } else {
      return _getPosAndDestinationMarkers();
    }
  }

  List<CircleMarker> _getAllMarkers() {
    print('========>>>> _getPosAndDestinationMarkers');
    int i = 0;
    List<CircleMarker> cm = [];
    if (iConfig != null) {
      iConfig!.floors[_getFloorIndexFromId(_selFloor)].items.forEach((msitem) {
        // If not in edit mode add only the itemid passed as parameter
        i++;
        print("$i ${widget.interactive} ${msitem.id} ${widget.itemid}");
        print('========>>>> ${msitem.latLng[0]}, ${msitem.latLng[1]}');
        cm.add(
          CircleMarker(
              point: LatLng(msitem.latLng[0], msitem.latLng[1]),
              color: Colors.amber.withOpacity(0.6),
              borderColor: Colors.green,
              borderStrokeWidth: 4,
              useRadiusInMeter: true,
              radius: .5 // 2000 meters | 2 km
              ),
        );
      });
    }
    return cm;
  }

  List<CircleMarker> _getPosAndDestinationMarkers() {
    print('========>>>> _getPosAndDestinationMarkers');
    int i = 0;
    List<CircleMarker> cm = [];
    if (iConfig != null) {
      iConfig!.floors[_getFloorIndexFromId(_selFloor)].items.forEach((msitem) {
        // If not in edit mode add only the itemid passed as parameter
        i++;
        // TODO: ADD also the myposition, if available...

        if (widget.interactive == false && msitem.id == widget.itemid) {
          print("$i ${widget.interactive} ${msitem.id} ${widget.itemid}");
          print('========>>>> ${msitem.latLng[0]}, ${msitem.latLng[1]}');
          cm.add(CircleMarker(
              point: LatLng(msitem.latLng[0], msitem.latLng[1]),
              color: Colors.amber.withOpacity(0.6),
              borderColor: Colors.red,
              borderStrokeWidth: 4,
              useRadiusInMeter: true,
              radius: .5 // 2000 meters | 2 km
              ));
        }

        if (widget.interactive == false && msitem.id == _locationId) {
          print("$i ${widget.interactive} ${msitem.id} ${widget.itemid}");
          print('========>>>> ${msitem.latLng[0]}, ${msitem.latLng[1]}');
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
              //_addNewMSItem();
              print('ADD NEW ITEM');
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
              // GenerateJSONConfig...
              //_generateJSonConfig();
            },
          ),
        ),
      );
    }
  }

/*  void _generateJSonConfig() {
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
*/

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
          imageProvider: NetworkImage(url),
        ),
      );
      mapController.fitBounds(_curBounds,
          options: FitBoundsOptions(
            maxZoom: 24,
            padding: EdgeInsets.only(left: 0, right: 0),
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
            //color: Colors.red,
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
                    onTap: (latLng) {
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
                    minZoom: 18.0,
                    interactiveFlags:
                        InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  ),
                  layers: [
                    /*TileLayerOptions(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                      maxZoom: 30,
                      maxNativeZoom: 30,
                    ),*/
                    OverlayImageLayerOptions(overlayImages: overlayImages),
                    CircleLayerOptions(circles: _getMarkers()),
                  ],
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
