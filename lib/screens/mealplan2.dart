import 'package:balancebite/dbHelper/mongodb.dart';
import 'package:flutter/material.dart';

class MealPlan2Screen extends StatefulWidget {
  final Map<String, dynamic> userData; // The user data passed from the previous screen

  MealPlan2Screen(this.userData);

  @override
  _MealPlan2ScreenState createState() => _MealPlan2ScreenState();
}

class _MealPlan2ScreenState extends State<MealPlan2Screen> {
  List<String> dietaryPreferences = [];
  List<String> allergies = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Image.asset('assets/arrow2.png'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Meal Plans',
          style: TextStyle(
            color: Color(0xFF74D9EA),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dietary Preferences Section
            Text(
              'Dietary Preferences',
              style: TextStyle(
                color: Color(0xFF74D9EA),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'What are your dietary preferences? You can select multiple.',
              style: TextStyle(color: Colors.white),
            ),
            _buildCheckboxOptions(
              ['Vegetarian', 'Vegan', 'Gluten-Free', 'No preferences'],
              dietaryPreferences,
            ),
            SizedBox(height: 30),

            // Allergies Section
            Text(
              'Allergies',
              style: TextStyle(
                color: Color(0xFF74D9EA),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Do you have any food allergies? You can select multiple.',
              style: TextStyle(color: Colors.white),
            ),
            _buildCheckboxOptions(
              ['Nuts', 'Dairy', 'Shellfish', 'No allergies'],
              allergies,
            ),
            Spacer(),
            // Next Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF74D9EA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () async {
                await _saveSelectionsToMongoDB();
                Navigator.pushNamed(context, '/mealPlan3');
              },
              child: Text(
                'Next',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build checkbox options
  Widget _buildCheckboxOptions(List<String> options, List<String> selectedList) {
    return Column(
      children: options.map((option) {
        return CheckboxListTile(
          value: selectedList.contains(option),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                selectedList.add(option);
              } else {
                selectedList.remove(option);
              }
            });
          },
          activeColor: Color(0xFF74D9EA),
          title: Text(
            option,
            style: TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
    );
  }

  // Save selected preferences and allergies in MongoDB
  Future<void> _saveSelectionsToMongoDB() async {
    try {
      final userId = widget.userData['_id']; // Get user ID from userData
      final updatedData = {
        'nutrition': {
          'dietaryPreferences': dietaryPreferences,
          'allergies': allergies,
        }
      };
      // Update user data in MongoDB
      await MongoDBService.updateUser(userId, updatedData);
    } catch (e) {
      print("Error saving user data: $e");
    }
  }
}
