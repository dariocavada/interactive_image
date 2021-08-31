import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager {
  static const key = 'interactiveImage';
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 300),
      maxNrOfCacheObjects: 100,
      repo: JsonCacheInfoRepository(databaseName: key),
      //fileSystem: IOFileSystem(key),
      fileService: HttpFileService(),
    ),
  );
}
