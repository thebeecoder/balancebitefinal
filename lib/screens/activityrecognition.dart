import 'package:balancebite/dbHelper/mongodb.dart'; // Make sure to import your MongoDB helper
import 'package:balancebite/screens/foodrecognition.dart';
import 'package:balancebite/screens/recommendation.dart';
import 'package:flutter/material.dart';
import 'activity_widget.dart'; // Import the activity widget
import 'home.dart'; // Make sure you import the home.dart to preserve navigation structure.

class ActivityRecognitionScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ActivityRecognitionScreen({super.key, required this.userData});

  @override
  _ActivityRecognitionScreenState createState() =>
      _ActivityRecognitionScreenState();
}

class _ActivityRecognitionScreenState extends State<ActivityRecognitionScreen> {
  String? _selectedActivity;

  // Extract weight from the user data (make sure it's part of the user data)
  double get _userWeight => widget.userData['weight'] ?? 70.0;  // Default weight if not found

  // Helper function to save activity to MongoDB
  Future<void> _saveActivity(String activityType, int duration, double caloriesBurned) async {
    final activityData = {
      "activity_type": activityType,
      "date": DateTime.now().toIso8601String(),  // Save current timestamp
      "duration": duration,
      "calories_burned": caloriesBurned,
    };

    try {
      final userId = widget.userData['_id'].toString(); 
      await MongoDBService.updateUserActivity(widget.userData['_id'], activityData);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Activity saved successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save activity: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF212020),
      body: SafeArea(
        child: Column(
          children: [
            // Place the menu and logo at the top, which remains constant as in `home.dart`
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
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
                Image.asset(
                  'assets/logobd.png',
                  width: 120,
                  semanticLabel: 'Nutrition Tracker Logo',
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            // Centralize the Activity Widget in the middle of the screen
            Expanded(
              child: SensorActivityDetector(
                onActivityDetected: (activityType, duration, caloriesBurned) {
                  // Save activity to MongoDB when detected
                  _saveActivity(activityType, duration, caloriesBurned);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: const Color(0xFF000000), // Set the background color of the bottom navigation to black
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
                  MaterialPageRoute(builder: (context) => ActivityRecognitionScreen(userData: widget.userData)),
                );
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecommendationDashboard(userData: widget.userData)),
                );
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/home.png')),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/food.png')),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/activity.png')),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/recommendation.png')),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
