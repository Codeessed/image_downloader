
class ImageItemModel {
  String id;
  String author;
  String downloadUrl;

  ImageItemModel({
    required this.id,
    required this.author,
    required this.downloadUrl,
  });

  Map toJson() {
    return {
      "id": id,
      'author': author,
      'download_url': downloadUrl,
    };
  }

  factory ImageItemModel.fromJson(Map<dynamic, dynamic> json) {
    return ImageItemModel(
      id: json['id'],
      author: json['author'],
      downloadUrl: json['download_url'],
    );
  }
}
