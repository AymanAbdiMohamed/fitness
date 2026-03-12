import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_entry.dart';

class NutritionService {
  static const String _entriesKey = 'food_entries';

  Future<List<FoodEntry>> loadAllEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_entriesKey) ?? [];
    return jsonList
        .map((s) => FoodEntry.fromJson(
            jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<List<FoodEntry>> loadTodayEntries() async {
    final all = await loadAllEntries();
    final today = DateTime.now();
    return all.where((entry) {
      return entry.dateAdded.year == today.year &&
          entry.dateAdded.month == today.month &&
          entry.dateAdded.day == today.day;
    }).toList();
  }

  Future<void> addEntry(FoodEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await loadAllEntries();
    all.add(entry);
    final jsonList = all.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_entriesKey, jsonList);
  }

  Future<void> deleteEntry(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await loadAllEntries();
    all.removeWhere((e) => e.id == id);
    final jsonList = all.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_entriesKey, jsonList);
  }

  List<FoodEntry> entriesForMeal(List<FoodEntry> entries, MealType mealType) {
    return entries.where((e) => e.mealType == mealType).toList();
  }

  int totalCaloriesForMeal(List<FoodEntry> entries, MealType mealType) {
    return entriesForMeal(entries, mealType)
        .fold(0, (sum, e) => sum + e.calories);
  }

  int totalCalories(List<FoodEntry> entries) {
    return entries.fold(0, (sum, e) => sum + e.calories);
  }
}
