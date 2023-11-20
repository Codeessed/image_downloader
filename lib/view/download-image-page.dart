
import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image_downloader/helpers/locator.dart';
import 'package:image_downloader/model/download-data-model.dart';
import 'package:image_downloader/model/image-item-model.dart';
import 'package:image_downloader/service/image-service.dart';
import 'package:image_downloader/view/common/downloads.dart';
import 'package:image_downloader/viewmodel/image-viewmodel.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'common/height-spacer.dart';

 Future<bool> downloadImage(List<dynamic> args) async {
  ImageService imageService = args[0];
  String imageUrl = args[1];
  SendPort sendPort = args[2];
  int imageIndex = args[3];
  RootIsolateToken? rootIsolateToken = args[4];
  DownloadDataModel initialDataModel = DownloadDataModel.fromJson(args[5]);
  bool? status;
  DownloadDataModel? downloadDataModel;
  String error = '';
  Uint8List? imageBytes;
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken!);
  try{
    Response response = await imageService.getImageBytes(imageUrl);
    imageBytes = response.bodyBytes;
    status = true;
    downloadDataModel = initialDataModel.copyWith(imageBytes: imageBytes, loading: false);
  }catch(e){
    error = e.toString();
    print(error);
    status = false;
    downloadDataModel = initialDataModel.copyWith(error: error, loading: false);
  }

  sendPort.send(downloadDataModel.toJson());
  return status;

}

 Future<bool> preprocessImage(List<dynamic> args) async {
  Uint8List bytes = args[0];
  SendPort sendPort = args[1];
  int imageIndex = args[2];
  RootIsolateToken? rootIsolateToken = args[3];
  DownloadDataModel initialDataModel = args[4];
  bool? status;
  DownloadDataModel? downloadDataModel;
  String error = '';
  Uint8List? processImageBytes;
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken!);
  try{
    img.Image image = img.decodeImage(bytes)!;
    image.frameType = img.FrameType.page;
    processImageBytes = image.buffer.asUint8List();
    // img.BlendMode.overlay;
    status = true;
    downloadDataModel = initialDataModel.copyWith(processImageBytes: processImageBytes, loading: false);
  }catch(e){
    error = e.toString();
    print(error);
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

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();

    List<ImageItemModel> pickedImageList = [];
    ImageViewModel viewModel = context.read<ImageViewModel>();
    pickedImageList.addAll(viewModel.imagesList.where((element) => widget.pickedImageIds.contains(element .id)));
    downloadData.addAll(
        List.generate(pickedImageList.length, (index) => DownloadDataModel(imageUrl: pickedImageList[index].downloadUrl, error: null, loading: true, imageBytes: null, processImageBytes: null))
    );
    downloadPagesList.addAll(
      downloadData.map((e) => ImageDownload(downloadData: e))
    );

    for(var i = 0; i < pickedImageList.length; i++){
      spawnDownloadIsolate(pickedImageList[i].downloadUrl, i, downloadData[i]);
    }



  }

  @override
  Widget build(BuildContext context) {

    ImageViewModel imageViewModel = context.watch<ImageViewModel>();

    Size size = MediaQuery.of(context).size;
    var screenHeight = size.height;

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              HeightSpacer(0.05),
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


  Future<void> spawnDownloadIsolate(String imageUrl, int downloadIndex, DownloadDataModel initialDataModel) async {
    final receivePort = ReceivePort();
    final sendPort = receivePort.sendPort;
    DownloadDataModel? downloadDataModel;
    ImageService imageService = locator<ImageService>();
    RootIsolateToken? rootIsolateToken = RootIsolateToken.instance;
    if (rootIsolateToken == null) {
      print("Cannot get the RootIsolateToken");
      downloadDataModel = initialDataModel.copyWith(error: 'Cannot get the RootIsolateToken', loading: false);
          // DownloadDataModel(image: null, error: 'Cannot get the RootIsolateToken', loading: false);
      // return;
    }

    receivePort.listen((message) {
      if (message is Map<dynamic, dynamic>) {
        downloadDataModel = DownloadDataModel.fromJson(message);
        print(message);
      } else {
        // Handle other types of messages if necessary
        downloadDataModel = initialDataModel.copyWith(error: 'An error has occurred', loading: false);
        print(message);
      }

      if (mounted) {
        setState(() {
          downloadData[downloadIndex] = downloadDataModel!;
          downloadPagesList[downloadIndex] = ImageDownload(downloadData: downloadData[downloadIndex]);
        });
        if(downloadData[downloadIndex].imageBytes != null){
          spawnProcessIsolate(downloadData[downloadIndex].imageBytes!, downloadIndex, initialDataModel);
        }

      }
      receivePort.close(); // Close the receive port to avoid memory leaks
    });

    try {
      await Isolate.spawn(
        downloadImage,
        [imageService, imageUrl, sendPort, downloadIndex, rootIsolateToken, initialDataModel.toJson()],
        onError: receivePort.sendPort,
        onExit: receivePort.sendPort,
      );
    } catch (e) {
      // Handle isolate spawn error
      print('Error spawning isolate: $e');
      downloadDataModel = initialDataModel.copyWith(error: 'Error spawning isolate $e', loading: false);
      if (mounted) {
        setState(() {
          downloadData[downloadIndex] = downloadDataModel!;
          downloadPagesList[downloadIndex] = ImageDownload(downloadData: downloadData[downloadIndex]);
        });
      }
    }
  }


  Future<void> spawnProcessIsolate(Uint8List imageBytes, int downloadIndex, DownloadDataModel initialDataModel) async {
    final receivePort = ReceivePort();
    final sendPort = receivePort.sendPort;
    DownloadDataModel? downloadDataModel;
    RootIsolateToken? rootIsolateToken = RootIsolateToken.instance;
    if (rootIsolateToken == null) {
      print("Cannot get the RootIsolateToken");
      downloadDataModel = initialDataModel.copyWith(error: 'Cannot get the RootIsolateToken', loading: false);
          // DownloadDataModel(image: null, error: 'Cannot get the RootIsolateToken', loading: false);
      // return;
    }

    receivePort.listen((message) {
      if (message is Map<dynamic, dynamic>) {
        downloadDataModel = DownloadDataModel.fromJson(message);
        print(message);
      } else {
        // Handle other types of messages if necessary
        downloadDataModel = initialDataModel.copyWith(error: 'An error has occurred', loading: false);
        print(message);
      }

      if (mounted) {
        setState(() {
          downloadData[downloadIndex] = downloadDataModel!;
          downloadPagesList[downloadIndex] = ImageDownload(downloadData: downloadData[downloadIndex]);
        });
      }
      receivePort.close(); // Close the receive port to avoid memory leaks
    });

    try {
      await Isolate.spawn(
        preprocessImage,
        [imageBytes, sendPort, downloadIndex, rootIsolateToken, initialDataModel],
        onError: receivePort.sendPort,
        onExit: receivePort.sendPort,
      );
    } catch (e) {
      // Handle isolate spawn error
      print('Error spawning isolate: $e');
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


