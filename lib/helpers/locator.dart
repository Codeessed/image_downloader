import 'package:get_it/get_it.dart';
import 'package:image_downloader/service/image-service.dart';

GetIt locator = GetIt.instance;

void setUpLocator() {
  locator.registerLazySingleton(() => ImageService());
}