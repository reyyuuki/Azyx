String formatDate(int timestamp) {
  if (timestamp <= 0) {
    return "N/A";
  }
  DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return "${date.day}/${date.month.toString().padLeft(2, '0')}/${date.year}";
}
