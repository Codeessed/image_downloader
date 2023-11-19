import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_downloader/helpers/constants/app-endpoint.dart';
import 'package:image_downloader/model/error-messages.dart';
import 'package:image_downloader/model/image-item-model.dart';


class ImageService{
  var client = http.Client();

  Future<List<ImageItemModel>> getImages() async {
    try {
      var response = await client
          .get(Uri.parse("${BASEURL}v2/list"));
      var data = jsonDecode(response.body);
      print(data);
      List<ImageItemModel> imageResponseModel = (data as List).map((e) => ImageItemModel.fromJson(e)).toList();
      return imageResponseModel;
    } on SocketException catch (_) {
      throw ErrorResponse("No internet connection");
    } on HttpException catch (_) {
      throw ErrorResponse("Service not currently available");
    } on TimeoutException catch (_) {
      throw ErrorResponse("Poor internet connection");
    } catch (e) {
      print(e);
      throw ErrorResponse("Something went wrong. Try again");
    }
  }

  Future<http.Response> getImageBytes(String imageUrl) async {
    try {
      var response = await client
          .get(Uri.parse(imageUrl));
      print(response);
      print(response.body);
      print(response.statusCode);
      print(response.bodyBytes);
      // var data = jsonDecode(response.body.toString());
      // print('data ${data}');
      return response;
    } on SocketException catch (_) {
      throw ErrorResponse("No internet connection");
    } on HttpException catch (_) {
      throw ErrorResponse("Service not currently available");
    } on TimeoutException catch (_) {
      throw ErrorResponse("Poor internet connection");
    } catch (e) {
      print(e);
      throw ErrorResponse("Something went wrong. Try again");
    }
  }


}