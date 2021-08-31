import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:interactive_image/src/models/iconfig.dart';
import 'package:interactive_image/src/shared/icache_manager.dart';
import 'package:interactive_image/src/shared/icached_image.dart';
import 'movable_stack_item.dart';
import 'dart:convert';

class InteractiveImage extends StatefulWidget {
  InteractiveImage({Key? key, required this.url}) : super(key: key);
  final String url;

  @override
  _InteractiveImageState createState() => _InteractiveImageState();
}

class _InteractiveImageState extends State<InteractiveImage> {
  List<Widget> stackItems = [];
  List<FloatingActionButton> floatinActionButtons = [];
  String _selImage = 'T';
  IConfig? iConfig;

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

  void _asyncInitializer() async {
    // TODO MANAGE NETWORK ERROR
    await CustomCacheManager.instance.emptyCache();
    FileInfo? fi2 =
        await CustomCacheManager.instance.getFileFromCache(widget.url);
    if (fi2 == null) {
      await CustomCacheManager.instance.downloadFile(widget.url);
    }
    var file = await CustomCacheManager.instance.getSingleFile(widget.url);

    iConfig = iConfigFromJson(file.readAsStringSync());
    setState(() {
      var a = iConfig!.floors[0];
      stackItems.add(
        IcachedImage(
          key: Key('imagemap'),
          imageurl: a.imageurl,
        ),
      );

      iConfig!.floors.forEach((floor) {
        floatinActionButtons.add(
          FloatingActionButton(
            backgroundColor:
                (_selImage == floor.id) ? Colors.orange : Colors.blue,
            child: Text(floor.id),
            onPressed: () {
              _changeImage(floor.imageurl, floor.id);
            },
          ),
        );
      });
    });
  }

  void _incrementCounter() {
    setState(() {
      stackItems.add(MoveableStackItem());
    });
  }

  void _changeImage(String imgUrl, String id) {
    int itemToDel = -1;

    for (int i = 0; i < stackItems.length; i++) {
      if (stackItems[i].key == Key('imagemap')) {
        itemToDel = i;
      }
    }

    if (itemToDel >= 0) {
      stackItems.removeAt(itemToDel);
    }
    setState(() {
      _selImage = id;
      stackItems.add(
        IcachedImage(
          key: Key('imagemap'),
          imageurl: imgUrl,
        ),
      );
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
            // transformationController:
            minScale: 0.1,
            maxScale: 3.0,
            constrained: true,
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
