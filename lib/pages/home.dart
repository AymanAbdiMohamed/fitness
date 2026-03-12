import 'package:flutter/material.dart';
import '../models/food_entry.dart';
import '../services/nutrition_service.dart';
import '../widgets/calorie_ring.dart';
import '../widgets/meal_section.dart';
import 'add_food_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NutritionService _nutritionService = NutritionService();
  List<FoodEntry> _todayEntries = [];
  int _waterGlasses = 0;
  static const int _waterGoal = 8;
  static const int _calorieGoal = 2000;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final entries = await _nutritionService.loadTodayEntries();
    if (mounted) {
      setState(() {
        _todayEntries = entries;
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToAddFood(MealType mealType) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddFoodPage(
          initialMealType: mealType,
          nutritionService: _nutritionService,
        ),
      ),
    );
    if (result == true) {
      await _loadData();
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    final weekday = days[now.weekday - 1];
    return '$weekday, ${months[now.month - 1]} ${now.day}';
  }

  int get _totalCalories => _nutritionService.totalCalories(_todayEntries);

  List<FoodEntry> _entriesFor(MealType type) =>
      _nutritionService.entriesForMeal(_todayEntries, type);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xff92A3FD),
              ),
            )
          : SafeArea(
              child: RefreshIndicator(
                color: const Color(0xff92A3FD),
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(),
                      const SizedBox(height: 28),
                      _buildCalorieSection(),
                      const SizedBox(height: 28),
                      _buildWaterSection(),
                      const SizedBox(height: 28),
                      _buildMealsSection(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getFormattedDate(),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xffF7F8F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.person_outline,
            color: Color(0xff92A3FD),
            size: 22,
          ),
        ),
      ],
    );
  }

  Widget _buildCalorieSection() {
    return Column(
      children: [
        const Text(
          'Daily Calories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Goal: 2000 kcal',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: CalorieRing(
            consumed: _totalCalories,
            goal: _calorieGoal,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildCalorieStat(
              'Carbs',
              '${(_totalCalories * 0.5).toInt()}',
              'kcal',
              const Color(0xff92A3FD),
            ),
            const SizedBox(width: 12),
            _buildCalorieStat(
              'Protein',
              '${(_totalCalories * 0.25).toInt()}',
              'kcal',
              const Color(0xff9DCEFF),
            ),
            const SizedBox(width: 12),
            _buildCalorieStat(
              'Fat',
              '${(_totalCalories * 0.25).toInt()}',
              'kcal',
              const Color(0xffEEA4CE),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalorieStat(
      String label, String value, String unit, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xffF7F8F8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              unit,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffF7F8F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Water Intake',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_waterGlasses / $_waterGoal glasses',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
              if (_waterGlasses > 0)
                GestureDetector(
                  onTap: () => setState(() {
                    if (_waterGlasses > 0) _waterGlasses--;
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xffE5E9FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.remove,
                      size: 16,
                      color: Color(0xff92A3FD),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(_waterGoal, (index) {
              final filled = index < _waterGlasses;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _waterGlasses = index + 1;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: filled
                          ? const LinearGradient(
                              colors: [Color(0xff92A3FD), Color(0xff9DCEFF)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          : null,
                      color: filled ? null : const Color(0xffE5E5E5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.water_drop,
                      size: 16,
                      color: filled ? Colors.white : Colors.grey.shade400,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          if (_waterGlasses < _waterGoal)
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_waterGlasses < _waterGoal) _waterGlasses++;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff92A3FD), Color(0xff9DCEFF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '+ Add a glass',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_waterGlasses == _waterGoal)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xffE5FFEE),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Daily goal reached!',
                style: TextStyle(
                  color: Color(0xff27AE60),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMealsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meals',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        ...MealType.values.map((mealType) => MealSection(
              mealType: mealType,
              entries: _entriesFor(mealType),
              onAddPressed: () => _navigateToAddFood(mealType),
            )),
      ],
    );
  }
}
