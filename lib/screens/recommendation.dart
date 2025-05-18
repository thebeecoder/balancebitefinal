
import 'package:balancebite/screens/activityrecognition.dart';
import 'package:balancebite/screens/foodrecognition.dart';
import 'package:balancebite/screens/home.dart';
import 'package:balancebite/screens/mealplan1.dart';
import 'package:balancebite/screens/exercise1.dart';
import 'package:flutter/material.dart';
import 'menu.dart';

class RecommendationDashboard extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const RecommendationDashboard({Key? key, this.userData}) : super(key: key);

  @override
  _RecommendationDashboardState createState() => _RecommendationDashboardState();
}

class _RecommendationDashboardState extends State<RecommendationDashboard> {
  Map<String, dynamic>? _userData;
  List<String> userGoals = ['Lose Weight']; // Changed to list for multiple goals

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
    _fetchUserGoals();
  }

  Future<void> _fetchUserGoals() async {
    try {
      if (_userData != null && _userData!['goals'] != null) {
        setState(() {
          userGoals = List<String>.from(_userData!['goals']);
        });
      }
    } catch (e) {
      print('Error fetching user goals: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF212020),
      drawer: MenuDrawer(userData: _userData),
      body: Builder(
        builder: (context) {
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Image.asset(
                          'assets/Menu.png',
                          width: 24,
                          height: 24,
                          color: Colors.white,
                        ),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                      Image.asset(
                        'assets/logobd.png',
                        width: 120,
                        semanticLabel: 'Nutrition Tracker Logo',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Recommendations',
                    style: TextStyle(
                      fontSize: 37,
                      fontFamily: 'Baloo',
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    "Here are some meal and exercise recommendations for you.",
                    style: TextStyle(
                      fontSize: 17,
                      fontFamily: 'Open Sans',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 21),
                  
                  // Goal Box
                  _buildBox(
                    title: "Your Goals",
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: userGoals.map((goal) => Text(
                        "• $goal",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          fontFamily: 'Inter',
                        ),
                      )).toList(),
                    ),
                    showButton: false,
                  ),

                  const SizedBox(height: 25),

                  // Meal Plan Box
                  _buildBox(
                    title: "Meal Plan",
                    content: Column(
                      children: [
                        const Text(
                          "Check your personalized nutrition plan",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 15),
                        Image.asset(
                          'assets/food.jpg',
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MealPlan1Screen(userData: _userData!)),
                    );
                    }
                  ),

                  const SizedBox(height: 25),

                  // Exercise Plan Box
                  _buildBox(
                    title: "Exercise Plan",
                    content: Column(
                      children: [
                        const Text(
                          "View your customized workout routine",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 15),
                        Image.asset(
                          'assets/exercise.jpg',
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ExercisePlan1Screen(userData: _userData!)),
                      );
                    },
                  ),
                  const SizedBox(height: 19),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: const Color(0xFF000000),
        ),
        child: BottomNavigationBar(
          selectedItemColor: const Color(0xFF74D9EA),
          unselectedItemColor: Colors.white54,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NutritionDashboard(widget.userData)),
                );
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FoodRecognition(userData: widget.userData)),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ActivityRecognitionScreen(userData: widget.userData!)),
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
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('assets/food.png'),
              ),
              activeIcon: ImageIcon(
                AssetImage('assets/food.png'),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('assets/activity.png'),
              ),
              activeIcon: ImageIcon(
                AssetImage('assets/activity.png'),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('assets/recommendation.png'),
              ),
              activeIcon: ImageIcon(
                AssetImage('assets/recommendation.png'),
                color: Color(0xFF74D9EA),
              ),
              label: '',
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Box Widget for Goal, Meal Plan, and Exercise Plan
  Widget _buildBox({
    required String title,
    required Widget content,
    VoidCallback? onPressed,
    bool showButton = true,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          content,
          if (showButton && onPressed != null) ...[
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF74D9EA),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text("See More"),
            ),
          ]
        ],
      ),
    );
  }
}