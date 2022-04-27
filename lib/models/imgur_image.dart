import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class ImgurImages {
  List<ImgurImage>? images;

  ImgurImages({this.images});

  factory ImgurImages.fromJson(Map<String, dynamic> json) => ImgurImages(
        images: List<ImgurImage>.from(
          json["data"].map(
            (x) => ImgurImage.fromJson(x),
          ),
        ),
      );
}

class ImgurImage {
  static int TYPE_PROGRESS = 1;
  static int TYPE_ITEM = 2;
  static int TYPE_ERROR = 3;
  final String link;
  final int itemType;

  ImgurImage({required this.link, required this.itemType});

  factory ImgurImage.fromJson(Map<String, dynamic> json) {
    if (json['type'] != null && json['type'] == "image/jpeg") {
      return ImgurImage(
        link: json['link'],
        itemType: ImgurImage.TYPE_ITEM,
      );
    }
    return ImgurImage(
      link: json['link'],
      itemType: ImgurImage.TYPE_PROGRESS,
    );
  }
}

Future<ImgurImages> fetchImages() async {
  final response = await http.get(
    Uri.parse('https://api.imgur.com/3/gallery/'),
    headers: {HttpHeaders.authorizationHeader: "Client-ID 0b3d1911da8bf87"},
  );
  if (response.statusCode == 200) {
    print(response.body);
    return ImgurImages.fromJson(json.decode(response.body));
  } else {
    print(response.body);
    throw Exception('Failed to fetch Images');
  }
}
