
import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_downloader/model/download-data-model.dart';
import 'package:image_downloader/model/image-item-model.dart';
import 'package:image_downloader/service/image-service.dart';
import 'package:image_downloader/view/common/downloads.dart';
import 'package:image_downloader/viewmodel/image-viewmodel.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'common/height-spacer.dart';

 Future<bool> downloadImage(List<dynamic> args) async {
  SendPort sendPort = args[0];
  DownloadDataModel initialDataModel = DownloadDataModel.fromJson(args[1]);
  String imageUrl = initialDataModel.imageUrl!;
  bool? status;
  DownloadDataModel? downloadDataModel;
  String error = '';
  Uint8List? imageBytes;
  try{
    http.Response response = await ImageService().getImageBytes(imageUrl);
    imageBytes = response.bodyBytes;
    status = true;
    downloadDataModel = initialDataModel.copyWith(imageBytes: imageBytes, loading: false);
  }catch(e){
    error = e.toString();
    status = false;
    downloadDataModel = initialDataModel.copyWith(error: error, loading: false);
  }

  sendPort.send(downloadDataModel.toJson());
  return status;

}

 Future<bool> preprocessImage(List<dynamic> args) async {
  SendPort sendPort = args[0];
  DownloadDataModel initialDataModel = DownloadDataModel.fromJson(args[1]);
  Uint8List bytes = initialDataModel.imageBytes!;
  bool? status;
  DownloadDataModel? downloadDataModel;
  String error = '';
  Uint8List? processImageBytes;
  try{
    img.Image image = img.decodeImage(bytes)!;
    image = img.copyRotate(image, angle: 90);
    image = img.grayscale(image);
    processImageBytes = Uint8List.fromList(img.encodeJpg(image));
    status = true;
    downloadDataModel = initialDataModel.copyWith(processImageBytes: processImageBytes, loading: false);
  }catch(e){
    error = e.toString();
    status = false;
    downloadDataModel = initialDataModel.copyWith(error: error, loading: false);
  }

  sendPort.send(downloadDataModel.toJson());
  return status;

}



class DownloadImage extends StatefulWidget {

  final List<String> pickedImageIds;
  const DownloadImage({Key? key, required this.pickedImageIds}) : super(key: key);

  @override
  State<DownloadImage> createState() => _DownloadImageState();
}

class _DownloadImageState extends State<DownloadImage> {

  int currentPageIndex = 0;
  List<Widget> downloadPagesList = [];
  List<DownloadDataModel> downloadData = [];
  List<ImageItemModel> pickedImageList = [];

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    ImageViewModel viewModel = context.read<ImageViewModel>();
    pickedImageList.addAll(viewModel.imagesList.where((element) => widget.pickedImageIds.contains(element .id)));
    downloadData.addAll(
        List.generate(pickedImageList.length, (index) => DownloadDataModel(imageUrl: pickedImageList[index].downloadUrl, error: null, loading: true, imageBytes: null, processImageBytes: null))
    );
    downloadPagesList.addAll(
      downloadData.map((e) => ImageDownload(downloadData: e))
    );

    for(var i = 0; i < pickedImageList.length; i++){
      spawnDownloadIsolate(i, downloadData[i]);
    }



  }

  @override
  Widget build(BuildContext context) {

    ImageViewModel imageViewModel = context.watch<ImageViewModel>();

    if(imageViewModel.retryDownload != null){
      var retryDownloadItem = imageViewModel.retryDownload!;
      var downloadItemIndex = pickedImageList.indexWhere((element) =>
      element.downloadUrl == retryDownloadItem.imageUrl
      );
      spawnDownloadIsolate(downloadItemIndex, DownloadDataModel(imageUrl: retryDownloadItem.imageUrl, error: null, loading: true, imageBytes: null, processImageBytes: null),);
      imageViewModel.retryImageDownload(null);
    }

    if(imageViewModel.retryPreprocess != null){
      var retryPreprocessItem = imageViewModel.retryPreprocess!;
      var preprocessItemIndex = pickedImageList.indexWhere((element) =>
      element.downloadUrl == retryPreprocessItem.imageUrl
      );
      spawnProcessIsolate(preprocessItemIndex, downloadData[preprocessItemIndex].copyWith(loading: true),);
      imageViewModel.retryPreprocessing(null);
    }

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeightSpacer(0.03),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: (){
                    Navigator.pop(context);
                  },
                    child: Icon(Icons.arrow_back)
                ),
              ),
              HeightSpacer(0.03),
              Expanded(
                child: PageView.builder(
                  onPageChanged: (value){
                    setState(() {
                      currentPageIndex = value;
                    });
                  },
                  itemCount: downloadPagesList.length,
                  controller: _pageController,
                    itemBuilder: (context, index){
                      return downloadPagesList[index];
                    }
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  width: double.maxFinite,
                  height: 12,
                  child: Center(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: downloadPagesList.length,
                        itemBuilder: (context, index){
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  currentPageIndex = index;
                                  _pageController.jumpToPage(currentPageIndex);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: index == currentPageIndex ? Colors.black : Colors.grey
                                ),
                                height: 10,
                                width: 10,
                              ),
                            ),
                          );
                        }
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ),
    );
  }


  Future<void> spawnDownloadIsolate(int downloadIndex, DownloadDataModel initialDataModel) async {
    final receivePort = ReceivePort();
    final sendPort = receivePort.sendPort;
    DownloadDataModel? downloadDataModel;

    receivePort.listen((message) {
      if (message is Map<dynamic, dynamic>) {
        downloadDataModel = DownloadDataModel.fromJson(message);
      } else {
        downloadDataModel = initialDataModel.copyWith(error: 'An error has occurred', loading: false);
      }

      if (mounted) {
        setState(() {
          downloadData[downloadIndex] = downloadDataModel!;
          downloadPagesList[downloadIndex] = ImageDownload(downloadData: downloadData[downloadIndex]);
        });
        if(downloadData[downloadIndex].imageBytes != null){
          setState(() {
            downloadData[downloadIndex] = downloadData[downloadIndex].copyWith(loading: true);
            downloadPagesList[downloadIndex] = ImageDownload(downloadData: downloadData[downloadIndex]);
          });
          spawnProcessIsolate(downloadIndex, downloadData[downloadIndex]);
        }

      }
      receivePort.close(); // Close the receive port to avoid memory leaks
    });

    try {
      await Isolate.spawn(
        downloadImage,
        [sendPort, initialDataModel.toJson()],
        onError: receivePort.sendPort,
        onExit: receivePort.sendPort,
      );
    } catch (e) {
      downloadDataModel = initialDataModel.copyWith(error: 'Error spawning isolate $e', loading: false);
      if (mounted) {
        setState(() {
          downloadData[downloadIndex] = downloadDataModel!;
          downloadPagesList[downloadIndex] = ImageDownload(downloadData: downloadData[downloadIndex]);
        });
      }
    }
  }


  Future<void> spawnProcessIsolate(int downloadIndex, DownloadDataModel initialDataModel) async {
    final receivePort = ReceivePort();
    final sendPort = receivePort.sendPort;
    DownloadDataModel? downloadDataModel;

    receivePort.listen((message) {
      if (message is Map<dynamic, dynamic>) {
        downloadDataModel = DownloadDataModel.fromJson(message);
      } else {
        downloadDataModel = initialDataModel.copyWith(error: 'An error has occurred', loading: false);
      }
      if (mounted) {
        setState(() {
          downloadData[downloadIndex] = downloadDataModel!;
          downloadPagesList[downloadIndex] = ImageDownload(downloadData: downloadData[downloadIndex]);
        });

      }
      receivePort.close();
    });

    try {
      await Isolate.spawn(
        preprocessImage,
        [sendPort, initialDataModel.toJson()],
        onError: receivePort.sendPort,
        onExit: receivePort.sendPort,
      );
    } catch (e) {
      downloadDataModel = initialDataModel.copyWith(error: 'Error spawning isolate', loading: false);
      if (mounted) {
        setState(() {
          downloadData[downloadIndex] = downloadDataModel!;
          downloadPagesList[downloadIndex] = ImageDownload(downloadData: downloadData[downloadIndex]);
        });
      }
    }
  }

}


