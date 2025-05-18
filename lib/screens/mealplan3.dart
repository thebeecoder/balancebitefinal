import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:balancebite/dbHelper/mongodb.dart';

class MealPlan3Screen extends StatefulWidget {
  final Map<String, dynamic> userData; // Accepting userData

  // Constructor to accept userData
  MealPlan3Screen(this.userData);

  @override
  _MealPlan3ScreenState createState() => _MealPlan3ScreenState();
}

class _MealPlan3ScreenState extends State<MealPlan3Screen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> mealPlans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Pass userData to fetch meal plans
  }

  

  // Function to filter meal plans by food type (Breakfast, Lunch, Dinner)
  List<dynamic> filterMealsByType(String mealType) {
    return mealPlans.where((meal) => meal['foodType'] == mealType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Ideas'),
        backgroundColor: Color(0xFF2D2D2D),
        elevation: 4,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Breakfast'),
            Tab(text: 'Lunch'),
            Tab(text: 'Dinner'),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                MealList(mealPlans: filterMealsByType('Breakfast')),
                MealList(mealPlans: filterMealsByType('Lunch')),
                MealList(mealPlans: filterMealsByType('Dinner')),
              ],
            ),
    );
  }
}

class MealList extends StatelessWidget {
  final List<dynamic> mealPlans;

  MealList({required this.mealPlans});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: mealPlans.length,
      itemBuilder: (context, index) {
        final meal = mealPlans[index];
        return MealCard(meal: meal);
      },
    );
  }
}

class MealCard extends StatelessWidget {
  final dynamic meal;

  MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 15.sp),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.sp),
      ),
      elevation: 6,
      color: Color(0xFF212121),
      child: Padding(
        padding: EdgeInsets.all(15.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15.sp),
              child: Image.network(
                meal['imageUrl'], // Assuming meal data contains an image URL
                width: double.infinity,
                height: 150.sp,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10.sp),
            Text(
              meal['foodName'],
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${meal['cookingTime']} min',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
                Text(
                  '${meal['calories']} Cal',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 10.sp),
            Text(
              'Ingredients: ${meal['ingredients'].join(', ')}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 10.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow, size: 18.sp),
                    SizedBox(width: 5.sp),
                    Text(
                      meal['dietaryPreferences'].join(', '),
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
