import 'package:flutter/material.dart';
import 'exercise2.dart'; // Importing ExercisePlan2Screen

class ExercisePlan1Screen extends StatelessWidget {
  final Map<String, dynamic> userData;

  // Constructor
  const ExercisePlan1Screen({super.key, required this.userData});

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
              'assets/ex.png', // Ensure the image is present in the assets folder
              fit: BoxFit.cover, // Ensures the image covers the whole screen
            ),
          ),
          // Content overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08, // 8% of screen width for horizontal padding
                vertical: screenHeight * 0.1, // 10% of screen height for vertical padding
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon + Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center, // A fitness icon
                        color: Colors.white,
                        size: screenWidth * 0.1, // Icon size based on screen width
                      ),
                      SizedBox(width: screenWidth * 0.02), // Space between icon and text
                      Text(
                        'Weekly Challenge',
                        style: TextStyle(
                          fontSize: screenWidth * 0.08, // Title font size based on screen width
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Baloo',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02), // Spacing between title and description
                  // Description
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1), // Horizontal padding based on screen width
                    child: Text(
                      'Get ready to push your limits and take on this week\'s challenge! Stay focused, follow the plan, and let\'s achieve greatness together. Are you ready for the challenge?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04, // Description font size based on screen width
                        color: Colors.white,
                        fontFamily: 'Open Sans',
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05), // Spacing before the button
                  // Start Now Button
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the ExercisePlan2Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExercisePlan2Screen(userData: userData), // Pass userData to ExercisePlan2Screen
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A4CFF), // Button color
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1, // Button padding based on screen width
                        vertical: screenHeight * 0.02, // Button padding based on screen height
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Start Now',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05, // Font size for the button text
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
