import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:image_downloader/helpers/locator.dart';
import 'package:image_downloader/model/download-data-model.dart';
import 'package:image_downloader/model/image-item-model.dart';
import 'package:image_downloader/service/image-service.dart';

class ImageViewModel extends ChangeNotifier{
  ImageService imageService = locator<ImageService>();

  final List<ImageItemModel> _imagesList = [];
  List<ImageItemModel> get imagesList => _imagesList;

  final List<DownloadDataModel> _downloadImagesList = [];
  List<DownloadDataModel> get downloadImagesList => _downloadImagesList;

  DownloadDataModel? _retryDownload;
  DownloadDataModel? get retryDownload => _retryDownload;

  DownloadDataModel? _retryPreprocess;
  DownloadDataModel? get retryPreprocess => _retryPreprocess;

  String _error = '';
  String get error => _error;

  bool _loading = false;
  bool get loading => _loading;

  Future<bool> getImages() async {
    _loading = true;
    notifyListeners();
    try{
      List<ImageItemModel> imageResponse = await imageService.getImages();
      print(imageResponse);
      _imagesList.clear();
      _imagesList.addAll(imageResponse);
      _loading = false;
      _error = '';
      notifyListeners();
      return true;
    }catch(e){
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
    return false;
  }

  Future<Response?> getImagesBytes(String imageUrl) async {
    try{
      Response? imageByteResponse = await imageService.getImageBytes(imageUrl);
        print(imageByteResponse.bodyBytes);
        return imageByteResponse;
    }catch(e){
      print('$e');
    }
    return null;
  }

  void retryImageDownload(DownloadDataModel? downloadDataModel){
    _retryDownload = downloadDataModel;
    notifyListeners();
  }

  void retryPreprocessing(DownloadDataModel? downloadDataModel){
    _retryPreprocess = downloadDataModel;
    notifyListeners();
  }

  void updateDownloadImageList(List<DownloadDataModel> downloadedImages){
    _downloadImagesList.clear();
    _downloadImagesList.addAll(downloadedImages);
    notifyListeners();
  }



}