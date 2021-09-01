import "package:flutter/material.dart";
import "../models/iconfig.dart";

Map<String, IconData> iconMapping = {
  'pin': Icons.pin_drop,
  'my_location': Icons.my_location,
  'home': Icons.home,
  'iconName': Icons.circle,
};

class MoveableStackItem extends StatefulWidget {
  MoveableStackItem({Key? key, required this.msitem, this.interactive = false})
      : super(key: key);

  final MSItem msitem;
  final bool interactive;

  @override
  State<StatefulWidget> createState() {
    return _MoveableStackItemState();
  }
}

class _MoveableStackItemState extends State<MoveableStackItem> {
  /*double xPosition = 0;
  double yPosition = 0;*/
  Color color = const Color.fromARGB(0xFF, 0x42, 0xA5, 0xF5);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.msitem.yPosition,
      left: widget.msitem.xPosition,
      child: GestureDetector(
        onPanUpdate: (tapInfo) {
          setState(() {
            widget.msitem.xPosition += tapInfo.delta.dx;
            widget.msitem.yPosition += tapInfo.delta.dy;
          });
        },
        child: Icon(
          iconMapping[widget.msitem.iconName],
          color: color,
        ), /*Container(
          width: 30,
          height: 30,
          color: color,
        ),*/
      ),
    );
  }
}
