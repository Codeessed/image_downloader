import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_downloader/model/download-data-model.dart';

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
    return Container(
      alignment: Alignment.center,
      width: double.maxFinite,
      height: double.maxFinite,
      child: widget.downloadData.loading ? const CircularProgressIndicator()
      : Column(
        children: [
          Expanded(
            child: widget.downloadData.imageBytes != null ?
            widget.downloadData.processImageBytes != null ? Image.memory(widget.downloadData.processImageBytes!)
                :Image.memory(widget.downloadData.imageBytes!) : Container()
          ),
          Text(
              '${widget.downloadData.error}'
          ),
          Text(
              '${widget.downloadData.loading}'
          ),
        ],
      )
    );
  }


   getBytes(String filename){
      final file = File(filename);
      file.readAsBytes();
  }
}