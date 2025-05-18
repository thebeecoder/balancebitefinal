import 'package:balancebite/screens/mealplan2.dart';
import 'package:flutter/material.dart';

class MealPlan1Screen extends StatelessWidget {
  final Map<String, dynamic> userData;

  // Constructor
  const MealPlan1Screen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    // Get screen size using MediaQuery
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return Scaffold(
      extendBodyBehindAppBar: true, // Allows the body to extend behind the app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Makes the app bar transparent
        elevation: 0, // Removes shadow
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/meal.png', // Ensure the image is present in the assets folder
              fit: BoxFit.cover, // Ensures the image covers the whole screen
              alignment: Alignment.center, // Centers the image if there is excess space
            ),
          ),
          // Content overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08, // 8% of screen width for padding
                vertical: screenHeight * 0.1, // 10% of screen height for padding
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    'Meal Plans',
                    style: TextStyle(
                      fontSize: screenWidth * 0.08, // Font size based on screen width
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Baloo',
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02), // Spacing between title and description
                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Discover the best meal plans for your fitness goals. Select from a variety of balanced and nutritious options designed to keep you energized throughout the day.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04, // Font size based on screen width
                        color: Colors.white,
                        fontFamily: 'Open Sans',
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05), // Spacing before the button
                  // Know Your Plan Button
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to MealPlan2Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MealPlan2Screen(userData),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A4CFF), // Button color
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1, // 10% of screen width for button padding
                        vertical: screenHeight * 0.02, // 2% of screen height for button padding
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Know Your Plan',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05, // Font size based on screen width
                        color: Colors.white,
                        fontFamily: 'Baloo',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
