
import 'dart:typed_data';

class DownloadDataModel {
  Uint8List? image;
  String? error;
  bool loading;

  DownloadDataModel({
    required this.image,
    required this.error,
    required this.loading,
  });

  DownloadDataModel copyWith({
    Uint8List? image,
    String? error,
    bool? loading,
  }) {
    return DownloadDataModel(
      image: image?? this.image,
      error: error?? this.error,
      loading: loading?? this.loading
    );
  }

  Map toJson() {
    return {
      "image": image,
      'error': error,
      'loading': loading,
    };
  }

  factory DownloadDataModel.fromJson(Map<dynamic, dynamic> json) {
    return DownloadDataModel(
      image: json['image'],
      error: json['error'],
      loading: json['loading'],
    );
  }
}
