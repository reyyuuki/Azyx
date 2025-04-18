class CarousaleData {
  String title;
  String image;
  int id;
  String? other;
  String? extraData;

  CarousaleData(
      {required this.id,
      required this.image,
      required this.title,
      this.other,
      this.extraData});
}
