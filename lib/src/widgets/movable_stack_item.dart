import "package:flutter/material.dart";

class MoveableStackItem extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MoveableStackItemState();
  }
}

class _MoveableStackItemState extends State<MoveableStackItem> {
  double xPosition = 0;
  double yPosition = 0;
  Color color = const Color.fromARGB(0xFF, 0x42, 0xA5, 0xF5);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: yPosition,
      left: xPosition,
      child: GestureDetector(
        onPanUpdate: (tapInfo) {
          setState(() {
            xPosition += tapInfo.delta.dx;
            yPosition += tapInfo.delta.dy;
          });
        },
        child: Container(
          width: 30,
          height: 30,
          color: color,
        ),
      ),
    );
  }
}
