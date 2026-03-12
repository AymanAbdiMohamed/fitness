import 'dart:convert';

enum MealType { breakfast, lunch, dinner, snacks }

extension MealTypeExtension on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snacks:
        return 'Snacks';
    }
  }

  static MealType fromString(String value) {
    switch (value) {
      case 'breakfast':
        return MealType.breakfast;
      case 'lunch':
        return MealType.lunch;
      case 'dinner':
        return MealType.dinner;
      case 'snacks':
        return MealType.snacks;
      default:
        return MealType.breakfast;
    }
  }
}

class FoodEntry {
  final String id;
  final String name;
  final int calories;
  final MealType mealType;
  final DateTime dateAdded;

  FoodEntry({
    required this.id,
    required this.name,
    required this.calories,
    required this.mealType,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'mealType': mealType.name,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      calories: json['calories'] as int,
      mealType: MealTypeExtension.fromString(json['mealType'] as String),
      dateAdded: DateTime.parse(json['dateAdded'] as String),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  static FoodEntry fromJsonString(String jsonString) =>
      FoodEntry.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}
