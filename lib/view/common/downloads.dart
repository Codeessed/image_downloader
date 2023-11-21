import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_downloader/model/download-data-model.dart';
import 'package:image_downloader/view/common/width-spacer.dart';
import 'package:image_downloader/viewmodel/image-viewmodel.dart';
import 'package:provider/provider.dart';

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

    ImageViewModel imageViewModel = context.watch<ImageViewModel>();

    print('image byte${widget.downloadData.imageBytes}');
    print('process image byte ${widget.downloadData.processImageBytes}');
    return imageWidget(downloadDataModel: widget.downloadData, viewModel: imageViewModel);
  }

  Widget imageWidget({
    required DownloadDataModel downloadDataModel,
    required ImageViewModel viewModel,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      child: CircularProgressIndicator(),
                    height: 20,
                    width: 20,
                  ),
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
                    viewModel.retryImageDownload(widget.downloadData);
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
                'Image preprocessing failed ${widget.downloadData.error}.',
                textAlign: TextAlign.center,
              ),
              TextButton(
                  onPressed: (){
                    viewModel.retryPreprocessing(widget.downloadData);
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
        List<DownloadDataModel> downloads = viewModel.downloadImagesList;
        downloads.add(downloadDataModel);
        viewModel.updateDownloadImageList(downloads);
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