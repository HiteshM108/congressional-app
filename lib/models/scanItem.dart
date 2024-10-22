class ScanItem {
  final String imageRequest, itemName, description, feedback, nutriScore;
  // final double calories, proteins, carbs, fats, cholesterol, sodium, sugar, nutriValue;
  final List<String> ingredients, nutrients;

  ScanItem({required this.imageRequest, required this.itemName, required this.description, required this.feedback, required this.nutriScore, required this.ingredients, required this.nutrients});

}


class ScanHistory {
  final List<Map<String, dynamic>> scanHistory;

  ScanHistory({required this.scanHistory});
}