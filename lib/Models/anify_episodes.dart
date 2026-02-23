import 'package:azyx/utils/time_formater.dart';

class AnifyEpisodes {
  String? title;
  String? image;
  String? description;
  String? dateUpload;
  bool? isFiller;
  bool? hasDub;
  int? number;
  int? id;
  String? url;

  AnifyEpisodes({
    this.dateUpload,
    this.description,
    this.hasDub,
    this.image,
    this.isFiller,
    this.number,
    this.title,
    this.url
  });

  factory AnifyEpisodes.fromJson(Map<String,dynamic> json,Map<String,dynamic> episode,int number){
    return AnifyEpisodes(
      url: episode['url'] ?? "",
      title: json['title'] ?? episode['name'],
      description: json['description'] ?? "",
      hasDub: json['hasDub'] ?? false,
      isFiller: json['isFiller'] ?? false,
      image: json['img'] ?? "",
      number: json['number'] ?? number,
      dateUpload: json['updatedAt'] != null ? formatDate(json['updatedAt']) : "??"
    );
  }
}