import "package:flutter/material.dart";
//import 'package:interactive_image/src/widgets/pulse_widget.dart';
import "../models/iconfig.dart";
import 'glow_widget.dart';

typedef StringCallback(String value);

extension ColorExtension on String {
  toColor() {
    var hexColor = this.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    } else {
      return Color.fromARGB(0xFF, 0x42, 0xA5, 0xF5);
    }
  }
}

Map<String, IconData> iconMapping = {
  'pin': Icons.pin_drop,
  'my_location': Icons.my_location,
  'home': Icons.home,
  'iconName': Icons.circle,
  'circle': Icons.circle,
};

class MoveableStackItem extends StatefulWidget {
  MoveableStackItem({
    Key? key,
    required this.msitem,
    required this.sy,
    required this.sx,
    required this.dx,
    required this.dy,
    this.interactive = false,
    this.pulse = false,
    this.iconname = '',
    this.iconcolor = '',
    this.onItemSelect,
  }) : super(key: key);

  final MSItem msitem;
  final bool interactive;
  final bool pulse;
  final String iconname;
  final String iconcolor;
  final double sy;
  final double sx;
  final double dy;
  final double dx;
  final StringCallback? onItemSelect;

  @override
  State<StatefulWidget> createState() {
    return _MoveableStackItemState();
  }
}

class _MoveableStackItemState extends State<MoveableStackItem> {
  /*double xPosition = 0;
  double yPosition = 0;*/

  @override
  void initState() {
    super.initState();
  }

  Widget _getCalcIcon() {
    String calcname = widget.iconname;
    if (calcname == '') {
      calcname = widget.msitem.iconName;
    }

    String calccolor = widget.iconcolor;
    if (calccolor == '') {
      calccolor = widget.msitem.fillcolor;
    }

    Color iconColor = calccolor.toColor();
    print('_getCalcIcon $calcname');
    if (widget.pulse == true) {
      return GlowWidget(
        child: Icon(
          iconMapping[calcname],
          color: iconColor,
        ),
      );
    } else {
      return Icon(
        iconMapping[calcname],
        color: iconColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.msitem.latLng[0] * widget.sy + widget.dy,
      left: widget.msitem.latLng[1] * widget.sx + widget.dx,
      child: GestureDetector(
        onTap: () {
          if (widget.onItemSelect != null) {
            widget.onItemSelect!(widget.msitem.id);
          } else {
            print('onTap ${widget.msitem.id}');
          }
        },
        onPanUpdate: (tapInfo) {
          setState(() {
            widget.msitem.latLng[0] += (tapInfo.delta.dx / widget.sx);
            widget.msitem.latLng[1] += (tapInfo.delta.dy / widget.sy);
          });
        },
        /*child: PulsingWidget(
              child: Icon(
                iconMapping[widget.msitem.iconName],
                color: color,
              ),
            ),*/
        child: _getCalcIcon(),
        /*Container(
              width: 30,
              height: 30,
              color: color,
            ),*/
      ),
    );
  }
}
