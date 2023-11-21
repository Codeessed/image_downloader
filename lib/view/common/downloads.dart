import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_downloader/model/download-data-model.dart';
import 'package:image_downloader/view/common/width-spacer.dart';

class ImageDownload extends StatefulWidget{

  final DownloadDataModel downloadData;
  const ImageDownload({super.key, required this.downloadData});


  @override
  State<StatefulWidget> createState() {
    return _ImageDownloadState();
  }

}

class _ImageDownloadState extends State<ImageDownload> {
  @override
  Widget build(BuildContext context) {

    print('image byte${widget.downloadData.imageBytes}');
    print('process image byte ${widget.downloadData.processImageBytes}');
    return imageWidget(downloadDataModel: widget.downloadData);
  }

  Widget imageWidget({
    required DownloadDataModel downloadDataModel
}){
    Widget? mainWidget;
    if(downloadDataModel.loading){
      if(downloadDataModel.imageBytes == null){
        mainWidget = Center(
          child: CircularProgressIndicator(),
        );
      }else{
        mainWidget = Column(
          children: [
            IntrinsicHeight(
              child: Row(
                children: [
                  Spacer(),
                  CircularProgressIndicator(),
                  WidthSpacer(0.03),
                  Text(
                    'Rotating and grayscaling image',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
                child: Image.memory(downloadDataModel.imageBytes!)
            )
          ],
        );
      }
    }else{
      if(downloadDataModel.processImageBytes == null){
        if(downloadDataModel.imageBytes == null){
          mainWidget = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.downloadData.error}',
                textAlign: TextAlign.center,
              ),
              TextButton(
                  onPressed: (){

                  },
                  child: Text(
                      'Retry Download'
                  )
              )
            ],
          );
        }else{
          mainWidget = Column(
            children: [
              Text(
                'Image preprocessing failed.',
                textAlign: TextAlign.center,
              ),
              TextButton(
                  onPressed: (){

                  },
                  child: Text(
                    'Try Again',
                  ),
              ),
              Expanded(
                  child: Image.memory(downloadDataModel.imageBytes!)
              )
            ],
          );
        }
      }else{
        mainWidget = Image.memory(downloadDataModel.processImageBytes!);
      }
    }

    return mainWidget;
  }


   getBytes(String filename){
      final file = File(filename);
      file.readAsBytes();
  }
}