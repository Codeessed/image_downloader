
import 'dart:convert';
import 'dart:typed_data';

class DownloadDataModel {
  Uint8List? imageBytes;
  Uint8List? processImageBytes;
  String? imageUrl;
  String? error;
  bool loading;

  DownloadDataModel({
    this.imageBytes,
    this.processImageBytes,
    this.imageUrl,
    this.error,
    required this.loading,
  });

  DownloadDataModel copyWith({
    Uint8List? imageBytes,
    Uint8List? processImageBytes,
    String? imageUrl,
    String? error,
    bool? loading,
  }) {
    return DownloadDataModel(
      imageBytes: imageBytes?? this.imageBytes,
        processImageBytes: processImageBytes?? this.processImageBytes,
        imageUrl: imageUrl?? this.imageUrl,
      error: error?? this.error,
      loading: loading?? this.loading
    );
  }

  Map toJson() {
    return {
      "image_bytes": imageBytes != null ? base64Encode(imageBytes!) : null,
      "process_image_bytes": processImageBytes != null ? base64Encode(processImageBytes!) : null,
      "image_url": imageUrl,
      'error': error,
      'loading': loading,
    };
  }

  factory DownloadDataModel.fromJson(Map<dynamic, dynamic> json) {
    return DownloadDataModel(
      imageBytes: json['image_bytes'] != null ? base64Decode(json['image_bytes']) : null,
      processImageBytes: json['process_image_bytes'] != null ? base64Decode(json['process_image_bytes']) : null,
      imageUrl: json['image_url'],
      error: json['error'],
      loading: json['loading'],
    );
  }
}
