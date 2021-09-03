import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'icache_manager.dart';

class IcachedImage extends StatelessWidget {
  const IcachedImage({
    Key? key,
    required this.imageurl,
    //this.fit = BoxFit.none,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  final String imageurl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageurl,
      fit: fit,
      progressIndicatorBuilder: (context, url, downloadProgress) => Center(
          child: CircularProgressIndicator(
        value: downloadProgress.progress,
      )),
      errorWidget: (context, url, error) => Icon(Icons.error),
      cacheManager: CustomCacheManager.instance,
    );
  }
}
