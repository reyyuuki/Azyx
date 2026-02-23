class SearchParams {
  String query;
  bool isManga;
  Map<String, dynamic>? filters;
  dynamic args;

  SearchParams({
    required this.query,
    this.isManga = false,
    this.filters,
    this.args,
  });
}
