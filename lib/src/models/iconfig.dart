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
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageurl,
    required this.items,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String imageurl;
  final List<Item> items;

  factory Floor.fromJson(Map<String, dynamic> json) => Floor(
        id: json["id"] ?? '',
        title: json["title"] ?? '',
        subtitle: json["subtitle"] ?? '',
        description: json["description"] ?? '',
        imageurl: json["imageurl"] ?? '',
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "subtitle": subtitle,
        "description": description,
        "imageurl": imageurl,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

class Item {
  Item({
    required this.id,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.type,
    required this.xPosition,
    required this.yPosition,
    required this.width,
    required this.height,
    required this.fillcolor,
    required this.bordercolor,
    required this.iconName,
  });

  final String id;
  final String number;
  final String title;
  final String subtitle;
  final String description;
  final String type;
  final int xPosition;
  final int yPosition;
  final int width;
  final int height;
  final String fillcolor;
  final String bordercolor;
  final String iconName;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"] ?? '',
        number: json["number"] ?? '',
        title: json["title"] ?? '',
        subtitle: json["subtitle"] ?? '',
        description: json["description"] ?? '',
        type: json["type"] ?? '',
        xPosition: json["xPosition"] ?? 0,
        yPosition: json["yPosition"] ?? 0,
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
        "xPosition": xPosition,
        "yPosition": yPosition,
        "width": width,
        "height": height,
        "fillcolor": fillcolor,
        "bordercolor": bordercolor,
        "iconName": iconName,
      };
}
