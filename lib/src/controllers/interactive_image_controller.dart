import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InteractiveImageController extends ChangeNotifier {
  String locationId = '';
  List<String> locationList = [];
  void setLocationId(String value) {
    this.locationId = value;
    notifyListeners();
  }
}
