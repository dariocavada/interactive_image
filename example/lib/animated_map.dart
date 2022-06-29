import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AnimatedMapControllerPage extends StatefulWidget {
  @override
  AnimatedMapControllerPageState createState() {
    return AnimatedMapControllerPageState();
  }
}

class AnimatedMapControllerPageState extends State<AnimatedMapControllerPage>
    with TickerProviderStateMixin {
  static LatLng london = LatLng(46.29177547878278, 11.458737395300826);
  static LatLng paris = LatLng(46.29157855872656, 11.459258968986305);
  static LatLng dublin = LatLng(53.3498, -6.2603);

  static LatLng a = LatLng(46.29177547878278, 11.458737395300826);
  static LatLng b = LatLng(46.29157855872656, 11.459258968986305);

  LatLng c = LatLng(46.29157855872656, 11.459258968986305);
  LatLng d = b;

  int curFloor = 0;

  List<String> imageUrls = [
    'https://s3-eu-west-1.amazonaws.com/mkspresprod.suggesto.eu/mdgcaritro/mappe/mcf/mcf-0.jpg',
    'https://s3-eu-west-1.amazonaws.com/mkspresprod.suggesto.eu/mdgcaritro/mappe/mcf/mcf-1.jpg',
    'https://s3-eu-west-1.amazonaws.com/mkspresprod.suggesto.eu/mdgcaritro/mappe/mcf/mcf-2.jpg',
  ];

  late final MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final _latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final _lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final _zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
          LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)),
          _zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    var overlayImages = <OverlayImage>[
      OverlayImage(
        bounds: LatLngBounds(
          a,
          b,
        ),
        opacity: 1,
        gaplessPlayback: true,
        imageProvider: NetworkImage(imageUrls[curFloor]),
      ),
    ];

    var markers = <Marker>[
      Marker(
        width: 20.0,
        height: 20.0,
        point: london,
        builder: (ctx) => Container(
          key: Key('blue'),
          child: Icon(Icons.circle, size: 20),
        ),
      ),
      Marker(
        width: 80.0,
        height: 80.0,
        point: dublin,
        builder: (ctx) => Container(
          key: Key('green'),
          child: Icon(Icons.circle, size: 20),
        ),
      ),
      Marker(
        width: 80.0,
        height: 80.0,
        point: paris,
        builder: (ctx) => Container(
          key: Key('purple'),
          child: Icon(Icons.circle, size: 20),
        ),
      ),
    ];

    var circleMarkers = <CircleMarker>[
      CircleMarker(
          point: c,
          color: Colors.amber.withOpacity(0.6),
          borderColor: Colors.red,
          borderStrokeWidth: 4,
          useRadiusInMeter: true,
          radius: .5 // 2000 meters | 2 km
          ),
      CircleMarker(
          point: d,
          color: Colors.blue.withOpacity(0.6),
          borderColor: Colors.blue,
          borderStrokeWidth: 4,
          useRadiusInMeter: true,
          radius: .5 // 2000 meters | 2 km
          ),
    ];
    return Scaffold(
      appBar: AppBar(title: Text('Animated MapController')),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      _animatedMapMove(london, 21.0);
                      setState(() {
                        curFloor = 0;
                      });
                    },
                    child: Text('London'),
                  ),
                  MaterialButton(
                    onPressed: () {
                      _animatedMapMove(paris, 21.0);
                      setState(() {
                        curFloor = 1;
                      });
                    },
                    child: Text('Paris'),
                  ),
                  MaterialButton(
                    onPressed: () {
                      _animatedMapMove(dublin, 21.0);
                      setState(() {
                        curFloor = 2;
                      });
                    },
                    child: Text('Dublin'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      var bounds = LatLngBounds();
                      bounds.extend(a);
                      bounds.extend(b);
                      mapController.fitBounds(
                        bounds,
                        options: FitBoundsOptions(
                          maxZoom: 24,
                          padding: EdgeInsets.only(left: 0.0, right: 0.0),
                        ),
                      );
                    },
                    child: Text('Fit Bounds'),
                  ),
                  MaterialButton(
                    onPressed: () {
                      var bounds = LatLngBounds();
                      bounds.extend(dublin);
                      bounds.extend(paris);
                      bounds.extend(london);

                      /*var centerZoom =
                          mapController.centerZoomFitBounds(bounds);
                      _animatedMapMove(centerZoom.center, centerZoom.zoom);*/
                    },
                    child: Text('Fit Bounds animated'),
                  ),
                ],
              ),
            ),
            Flexible(
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  bounds: LatLngBounds(
                    a,
                    b,
                  ),
                  boundsOptions: FitBoundsOptions(
                    maxZoom: 24,
                    padding: EdgeInsets.only(left: 0.0, right: 0.0),
                  ),

                  //center: a,
                  /*swPanBoundary: b,
                  nePanBoundary: a,
                  slideOnBoundaries: true,
                  screenSize: MediaQuery.of(context).size,*/
                  //slideOnBoundaries: false,
                  //adaptiveBoundaries: true,
                  //boundsOptions: FitBoundsOptions,
                  onTap: (tapPosition, latLng) {
                    print('Lat: ${latLng.latitude}, Lng:${latLng.latitude}');
                    setState(() {
                      c.latitude = latLng.latitude;
                      c.longitude = latLng.longitude;
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
                  /*TileLayerOptions(
                    urlTemplate:
                        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                    maxZoom: 30,
                    maxNativeZoom: 30,
                  ),*/

                  OverlayImageLayerOptions(overlayImages: overlayImages),
                  MarkerLayerOptions(markers: markers),
                  CircleLayerOptions(circles: circleMarkers),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
