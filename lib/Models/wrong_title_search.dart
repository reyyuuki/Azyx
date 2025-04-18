class WrongTitleSearch {
  String? image;
  String? link;
  String? tilte;

  WrongTitleSearch({
    this.image,
    this.link,
    this.tilte
  });

  factory WrongTitleSearch.fromJson(Map<String,dynamic> json){
    return WrongTitleSearch(
      tilte: json['name'] ?? "Unknown",
      link: json['link'] ?? "",
      image: json['imageUrl']
    );
  }
}