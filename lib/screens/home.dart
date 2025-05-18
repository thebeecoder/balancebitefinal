import 'dart:math';
import 'dart:ui';
import 'package:balancebite/screens/activityrecognition.dart';
import 'package:balancebite/screens/recommendation.dart';

import 'foodrecognition.dart';
import 'package:flutter/material.dart';
import 'menu.dart';

class NutritionDashboard extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const NutritionDashboard(this.userData, {Key? key}) : super(key: key);

    @override
  _NutritionDashboardState createState() => _NutritionDashboardState();
}

class _NutritionDashboardState extends State<NutritionDashboard> {
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
  }

  void _updateProfile(Map<String, dynamic> updatedData) {
    setState(() {
      _userData = updatedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final firstName = _userData!['full_name']?.toString().split(' ').first ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xFF212020),
      drawer: MenuDrawer(userData: _userData, onProfileUpdated: _updateProfile,), // Add the MenuDrawer here
      body: Builder(
        builder: (context) {
          return SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(maxWidth: screenWidth),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Menu Icon to open the drawer
                      IconButton(
                        icon: Image.asset(
                          'assets/Menu.png',
                          width: 24,
                          height: 24,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Scaffold.of(context).openDrawer(); // Open the drawer
                        },
                      ),
                      Image.asset(
                        'assets/logobd.png',
                        width: 120,
                        semanticLabel: 'Nutrition Tracker Logo',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 37,
                        fontFamily: 'Baloo',
                        color: Colors.white,
                      ),
                      children: [
                        const TextSpan(text: 'Hello '),
                        TextSpan(text: '$firstName,'),
                      ],
                    ),
                  ),
                  const Text(
                    "It's time to challenge your limits.",
                    style: TextStyle(
                      fontSize: 17,
                      fontFamily: 'Open Sans',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 21),
                  const ProgressCircle(
                    currentCalories: 1000,
                    targetCalories: 1200,
                  ),
                  const SizedBox(height: 5),
                  const MacroNutrientsBar(),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: CalorieChart(
                          title: 'Calories Intake',
                          value: 7500,
                        ),
                      ),
                      const SizedBox(width: 17),
                      Expanded(
                        child: CalorieChart(
                          title: 'Calories Burnt',
                          value: 00,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 19),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: const Color(0xFF000000), // Background color for the navigation bar
        ),
        child: BottomNavigationBar(
          selectedItemColor: const Color(0xFF74D9EA), // Color for selected item
          unselectedItemColor: Colors.white54, // Color for unselected items
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (index) {
            // Handle navigation based on the index
            switch (index) {
              case 0:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NutritionDashboard(_userData)),
                );
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FoodRecognition(userData: _userData)),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ActivityRecognitionScreen(userData: _userData!)),
                );
                break;
              case 3:
                Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RecommendationDashboard(userData: widget.userData!)),

                );
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('assets/home.png'),
              ),
              activeIcon: ImageIcon(
                AssetImage('assets/home.png'),
                color: Color(0xFF74D9EA), // Color for selected icon
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('assets/food.png'), // Default color for unselected icon
              ),
              activeIcon: ImageIcon(
                AssetImage('assets/food.png'), // Color for selected icon
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('assets/activity.png'),
                color: Colors.white54, // Default color for unselected icon
              ),
              activeIcon: ImageIcon(
                AssetImage('assets/activity.png'),
                color: Color(0xFF74D9EA), // Color for selected icon
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('assets/recommendation.png'),
                color: Colors.white54, // Default color for unselected icon
              ),
              activeIcon: ImageIcon(
                AssetImage('assets/recommendation.png'),
                color: Color(0xFF74D9EA), // Color for selected icon
              ),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressCircle extends StatelessWidget {
  final int currentCalories;
  final int targetCalories;

  const ProgressCircle({
    Key? key,
    required this.currentCalories,
    required this.targetCalories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 78),
      decoration: BoxDecoration(
        color: const Color(0xFF74D9EA),
        borderRadius: BorderRadius.circular(29),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(130, 110),
            painter: DashedCirclePainter(),
          ),
          Container(
            width: 204,
            height: 204,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE2F163),
                width: 19,
              ),
            ),
          ),
          Container(
            width: 166,
            height: 166,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF549D4C),
                width: 5,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Baloo Bhai',
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: '$currentCalories\n',
                      style: const TextStyle(fontSize: 25),
                    ),
                    const TextSpan(
                      text: 'kcal',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
              Text(
                '/$targetCalories Kcal',
                style: const TextStyle(
                  fontFamily: 'Baloo Bhai',
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF549D4C)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final path = Path()..addArc(Rect.fromLTWH(0, 0, size.width, size.height), 0, 2 * pi);

    final Path dashedPath = Path();
    const double dashWidth = 15;
    const double dashSpace = 10;
    final PathMetrics pathMetrics = path.computeMetrics();
    
    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0;
      while (distance < pathMetric.length) {
        final double length = (distance + dashWidth < pathMetric.length) ? dashWidth : pathMetric.length - distance;
        dashedPath.addPath(pathMetric.extractPath(distance, distance + length), Offset.zero);
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class MacroNutrientsBar extends StatelessWidget {
  const MacroNutrientsBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 101,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(29),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          MacroNutrient(
            label: 'Carbs',
            current: 88,
            target: 120,
            progress: 0.73,
          ),
          MacroNutrient(
            label: 'Protein',
            current: 50,
            target: 70,
            progress: 0.71,
          ),
          MacroNutrient(
            label: 'Fat',
            current: 30,
            target: 50,
            progress: 0.60,
          ),
        ],
      ),
    );
  }
}

class MacroNutrient extends StatelessWidget {
  final String label;
  final int current;
  final int target;
  final double progress;

  const MacroNutrient({
    Key? key,
    required this.label,
    required this.current,
    required this.target,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: '$current',
                style: const TextStyle(fontSize: 27),
              ),
              TextSpan(
                text: '/${target}g',
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xB3000000),
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              width: 80,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            Container(
              width: 80 * progress,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CalorieChart extends StatelessWidget {
  final String title;
  final int value;

  const CalorieChart({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F163),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$value kcal',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

