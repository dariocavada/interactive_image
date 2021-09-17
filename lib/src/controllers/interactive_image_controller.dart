import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../models/iconfig.dart';

class InteractiveImageController extends ChangeNotifier {
  String locationId = '';
  String changeId = '';
  double latitude = 0;
  double longitude = 0;

  MSItem msitem = new MSItem(
    id: '',
    number: '',
    title: '',
    subtitle: '',
    description: '',
    type: '',
    latLng: [0, 0],
    width: 10,
    height: 10,
    fillcolor: '',
    bordercolor: '',
    iconName: 'iconName',
  );

  List<String> locationList = [];

  void setChangeId(String value) {
    print('InteractiveImageController setChangeId $value');
    this.changeId = value;
    notifyListeners();
  }

  void setLocationId(String value) {
    print('InteractiveImageController setLocationId $value');
    this.locationId = value;
    notifyListeners();
  }
}
