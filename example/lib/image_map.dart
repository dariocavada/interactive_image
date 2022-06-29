import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';

class OverlayImagePage extends StatefulWidget {
  static const String route = 'overlay_image';

  @override
  _OverlayImagePageState createState() => _OverlayImagePageState();
}

class _OverlayImagePageState extends State<OverlayImagePage> {
  List<LatLng> tappedPoints = [];
  LatLngBounds _bounds = LatLngBounds(
    LatLng(46.29177547878278, 11.458737395300826),
    LatLng(46.29157855872656, 11.459258968986305),
  );
  final MapController mapController = MapController();

  @override
  void initState() {
    print('>>>>>> initState');
    //mapController = MapController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var overlayImages = <OverlayImage>[
      OverlayImage(
        bounds: LatLngBounds(
          LatLng(46.29177547878278, 11.458737395300826),
          LatLng(46.29157855872656, 11.459258968986305),
        ),
        opacity: 1,
        gaplessPlayback: true,
        imageProvider: NetworkImage(
            'https://s3-eu-west-1.amazonaws.com/mkspresprod.suggesto.eu/mdgcaritro/mappe/mcf/mcf-0.jpg'),
      ),
    ];

/*

MapOptions(
  bounds: LatLngBounds(LatLng(58.8, 6.1), LatLng(59, 6.2)),
  boundsOptions: FitBoundsOptions(padding: EdgeInsets.all(8.0)),
),
*/

    return Scaffold(
      appBar: AppBar(title: Text('Overlay Image')),
      //drawer: buildDrawer(context, route),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text('This is a map that is showing (51.5, -0.9).'),
            ),
            Flexible(
              child: FlutterMap(
                options: MapOptions(
                  //interactiveFlags: ,
                  bounds: LatLngBounds(
                    LatLng(46.29177547878278, 11.458737395300826),
                    LatLng(46.29157855872656, 11.459258968986305),
                  ),
                  boundsOptions: FitBoundsOptions(padding: EdgeInsets.all(8.0)),

                  //center: LatLng(46.291699930920416, 11.45901520946318),
                  zoom: 6.0,
                  onTap: _handleTap,
                  interactiveFlags:
                      InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
                layers: [
                  TileLayerOptions(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c']),
                  OverlayImageLayerOptions(overlayImages: overlayImages),
                  MarkerLayerOptions(
                    markers: [
                      Marker(
                        width: 20.0,
                        height: 20.0,
                        point: LatLng(46.29177547878278, 11.458737395300826),
                        builder: (ctx) => Container(
                          child: Icon(Icons.circle, size: 20),
                        ),
                      ),
                      Marker(
                        width: 20.0,
                        height: 20.0,
                        point: LatLng(46.29157855872656, 11.459258968986305),
                        builder: (ctx) => Container(
                          child: Icon(Icons.circle, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(TapPosition tapPos, LatLng latlng) {
    print('${latlng.latitude} ${latlng.longitude} ');
    setState(() {
      tappedPoints.add(latlng);
      mapController.fitBounds(
        _bounds,
        options: FitBoundsOptions(
          padding: EdgeInsets.only(left: 15, right: 15),
        ),
      );
    });
  }
}
