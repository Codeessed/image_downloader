import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:image_downloader/helpers/locator.dart';
import 'package:image_downloader/model/image-item-model.dart';
import 'package:image_downloader/service/image-service.dart';

class ImageViewModel extends ChangeNotifier{
  ImageService imageService = locator<ImageService>();

  final List<ImageItemModel> _imagesList = [];
  List<ImageItemModel> get imagesList => _imagesList;

  Future<bool> getImages() async {
    try{
      List<ImageItemModel> imageResponse = await imageService.getImages();
      if(imageResponse.isNotEmpty){
        print(imageResponse);
        _imagesList.clear();
        _imagesList.addAll(imageResponse);
        notifyListeners();
        return true;
      }
    }catch(e){
      print('error fetching images $e');
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


}