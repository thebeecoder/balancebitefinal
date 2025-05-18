import 'package:balancebite/dbHelper/mongodb.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'activity.dart';

class GoalSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const GoalSelectionScreen({
    Key? key,
    required this.userData, // This is now the only definition
  }) : super(key: key);

  @override
  _GoalSelectionScreenState createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  List<String> selectedGoals = []; // This will hold multiple selected goals

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Semantics(
      label: 'Goal Selection Screen',
      child: Scaffold(
        backgroundColor: const Color(0xFF232323),
        appBar: AppBar(
          backgroundColor: const Color(0xFF232323),
          elevation: 0,
          leading: const CustomBackButton(),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, // 5% of screen width
              vertical: screenHeight * 0.02, // 2% of screen height
            ),
            child: Column(
              children: [
                Text(
                  'What Is Your Goal?',
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.06, // Responsive font size
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03), // 3% of screen height
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Text(
                    'Setting a clear goal is the first step towards achieving your health and fitness dreams. Choose a goal that inspires you and take the first step today!',
                    style: GoogleFonts.leagueSpartan(
                      fontSize: screenWidth * 0.035, // Responsive font size
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.04), // 4% of screen height
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.03, // 3% of screen height
                    horizontal: screenWidth * 0.05, // 5% of screen width
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF74D9EA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _buildGoalOption('Lose Weight'),
                      _buildGoalOption('Gain Weight'),
                      _buildGoalOption('Muscle Mass Gain'),
                      _buildGoalOption('Shape Body'),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03), // 3% of screen height
                ContinueButton(
                  isEnabled: selectedGoals.isNotEmpty, // Enable if any goal is selected
                  onPressed: _handleContinue,
                ),
                SizedBox(height: screenHeight * 0.05), // 5% of screen height
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalOption(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02), // 2% of screen height
      child: GoalOptionCard(
        label: label,
        isSelected: selectedGoals.contains(label),
        onSelect: () => setState(() {
          if (selectedGoals.contains(label)) {
            selectedGoals.remove(label); // Deselect if already selected
          } else {
            selectedGoals.add(label); // Select if not already selected
          }
        }),
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (selectedGoals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one goal')),
      );
      return;
    }

    try {
      // Update user data with selected goals
      final updatedUserData = {
        ...widget.userData,
        'goals': selectedGoals, // Store all selected goals
      };

      // Save to database
      await MongoDBService.updateUsergoal(
        updatedUserData['_id'],
        selectedGoals.join(', '), // Join the list of selected goals into a single string
      );

      // Navigate to the next screen with updated data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhysicalActivityScreen(
            userData: updatedUserData,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving goal: $e')),
      );
    }
  }
}

class GoalOptionCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelect;

  const GoalOptionCard({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Select $label as goal',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        child: InkWell(
          borderRadius: BorderRadius.circular(36),
          onTap: onSelect,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05, // 5% of screen width
              vertical: MediaQuery.of(context).size.height * 0.02, // 2% of screen height
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.leagueSpartan(
                      fontSize: MediaQuery.of(context).size.width * 0.045, // Responsive font size
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF232323),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.09, // 9% of screen width
                  height: MediaQuery.of(context).size.width * 0.09, // 9% of screen width
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color(0xFFE2F163) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? const Color(0xFFE2F163) : const Color(0xFF232323),
                      width: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Go back',
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.arrow_back_ios,
              size: 12,
              color: Color(0xFFE2F163),
            ),
            const SizedBox(width: 9),
            Text(
              'Back',
              style: GoogleFonts.leagueSpartan(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE2F163),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContinueButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onPressed;

  const ContinueButton({
    Key? key,
    required this.isEnabled,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Continue to next step',
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 199,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Colors.white.withOpacity(isEnabled ? 0.09 : 0.05), // Adjust opacity based on enabled state
            ),
          ),
          Container(
            width: 199,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: isEnabled ? Colors.white : Colors.grey, // Adjust border color based on enabled state
                width: 0.5,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? onPressed : null, // Disable onTap if not enabled
              borderRadius: BorderRadius.circular(100),
              child: Container(
                width: 199,
                height: 44,
                alignment: Alignment.center,
                child: Text(
                  'Continue',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isEnabled ? Colors.white : Colors.grey, // Adjust text color based on enabled state
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
