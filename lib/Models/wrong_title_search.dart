class WrongTitleSearch {
  String? image;
  String? link;
  String? title;

  WrongTitleSearch({this.image, this.link, this.title});

  factory WrongTitleSearch.fromJson(Map<String, dynamic> json) {
    return WrongTitleSearch(
        title: json['name'] ?? "Unknown",
        link: json['link'] ?? "",
        image: json['imageUrl']);
  }
}
