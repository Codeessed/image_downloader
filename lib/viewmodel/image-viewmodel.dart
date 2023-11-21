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

  void retryImageDownload(DownloadDataModel? downloadDataModel){
    _retryDownload = downloadDataModel;
    notifyListeners();
  }

  void retryPreprocessing(DownloadDataModel? downloadDataModel){
    _retryPreprocess = downloadDataModel;
    notifyListeners();
  }



}