// To parse this JSON data, do
//
//     final iConfig = iConfigFromJson(jsonString);

import 'dart:convert';

IConfig iConfigFromJson(String str) => IConfig.fromJson(json.decode(str));

String iConfigToJson(IConfig data) => json.encode(data.toJson());

class IConfig {
  IConfig({
    required this.id,
    required this.name,
    required this.floors,
  });

  final String id;
  final String name;
  final List<Floor> floors;

  factory IConfig.fromJson(Map<String, dynamic> json) => IConfig(
        id: json["id"] ?? '',
        name: json["name"] ?? '',
        floors: List<Floor>.from(json["floors"].map((x) => Floor.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "floors": List<dynamic>.from(floors.map((x) => x.toJson())),
      };
}

class Floor {
  Floor({
    required this.id,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.latLngBounds,
    required this.imageurl,
    required this.items,
  });

  final String id;
  final String label;
  final String title;
  final String subtitle;
  final String description;
  final List<List<double>> latLngBounds;
  final String imageurl;
  final List<MSItem> items;

  factory Floor.fromJson(Map<String, dynamic> json) => Floor(
        id: json["id"] ?? '',
        label: json["label"] ?? json["id"] ?? "",
        title: json["title"] ?? '',
        subtitle: json["subtitle"] ?? '',
        description: json["description"] ?? '',
        latLngBounds: List<List<double>>.from(json["latLngBounds"]
            .map((x) => List<double>.from(x.map((x) => x.toDouble())))),
        imageurl: json["imageurl"] ?? '',
        items: List<MSItem>.from(json["items"].map((x) => MSItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "label": label,
        "title": title,
        "subtitle": subtitle,
        "description": description,
        "latLngBounds": List<dynamic>.from(
            latLngBounds.map((x) => List<dynamic>.from(x.map((x) => x)))),
        "imageurl": imageurl,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

class MSItem {
  MSItem({
    required this.id,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.type,
    required this.latLng,
    required this.width,
    required this.height,
    required this.fillcolor,
    required this.bordercolor,
    required this.iconName,
  });

  String id;
  String number;
  String title;
  String subtitle;
  String description;
  String type;
  List<double> latLng;
  int width;
  int height;
  String fillcolor;
  String bordercolor;
  String iconName;

  factory MSItem.fromJson(Map<String, dynamic> json) => MSItem(
        id: json["id"] ?? '',
        number: json["number"] ?? '',
        title: json["title"] ?? '',
        subtitle: json["subtitle"] ?? '',
        description: json["description"] ?? '',
        type: json["type"] ?? '',
        latLng: List<double>.from(json["latLng"].map((x) => x.toDouble())),
        width: json["width"] ?? 10,
        height: json["height"] ?? 10,
        fillcolor: json["fillcolor"] ?? '',
        bordercolor: json["bordercolor"] ?? '',
        iconName: json["iconName"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "number": number,
        "title": title,
        "subtitle": subtitle,
        "description": description,
        "type": type,
        "latLng": List<dynamic>.from(latLng.map((x) => x)),
        "width": width,
        "height": height,
        "fillcolor": fillcolor,
        "bordercolor": bordercolor,
        "iconName": iconName,
      };
}
