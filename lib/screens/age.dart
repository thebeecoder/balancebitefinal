import 'package:balancebite/dbHelper/mongodb.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'weight.dart';

class AgeSelectorScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const AgeSelectorScreen(this.userData, {Key? key}) : super(key: key);

  @override
  _AgeSelectorScreenState createState() => _AgeSelectorScreenState();
}

class _AgeSelectorScreenState extends State<AgeSelectorScreen> {
  int selectedAge = 28;
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(initialItem: selectedAge - 25);
  }

  Future<void> _updateAge() async {
    try {
      await MongoDBService.updateUserAge(widget.userData['_id'], selectedAge.toString());
      final updatedData = Map<String, dynamic>.from(widget.userData)..['age'] = selectedAge;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WeightSelectorScreen(updatedData)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update age. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            SizedBox(height: screenHeight * 0.02),
            _buildTitle(),
            SizedBox(height: screenHeight * 0.015),
            _buildDescription(),
            SizedBox(height: screenHeight * 0.04),
            _buildSelectedAge(screenWidth),
            Expanded(child: _buildAgePicker(screenWidth)),
            _buildContinueButton(screenWidth),
            SizedBox(height: screenHeight * 0.04),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 10),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/Arrow2.png', // Ensure this path is correct in pubspec.yaml
                                width: 16,
                                height: 16,
                                color: const Color(0xFFE2F163),
                              ),
                              const SizedBox(width: 8),
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
                      ),
                    );
  }

  Widget _buildTitle() {
    return Text(
      'How Old Are You?',
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        'Select your age to personalize your calorie tracking experience.',
        textAlign: TextAlign.center,
        style: GoogleFonts.leagueSpartan(
          color: Colors.white.withOpacity(0.6),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildSelectedAge(double screenWidth) {
    return Text(
      selectedAge.toString(),
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: screenWidth * 0.16, // Scales with screen width
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildAgePicker(double screenWidth) {
    return Container(
      height: screenWidth * 0.3,
      child: ListWheelScrollView.useDelegate(
        controller: _scrollController,
        itemExtent: 70,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          setState(() {
            selectedAge = 10 + index;
          });
        },
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final age = 10 + index;
            final isSelected = age == selectedAge;

            return Center(
              child: Text(
                age.toString(),
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.white54,
                  fontSize: isSelected ? screenWidth * 0.08 : screenWidth * 0.06,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          },
          childCount: 76,
        ),
      ),
    );
  }

  Widget _buildContinueButton(double screenWidth) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
    child: ElevatedButton(
      onPressed: selectedAge > 0 ? _updateAge : null, // Disable if age is not selected
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedAge > 0
            ? const Color(0xFFE2F163) // Enabled button color
            : const Color(0xFFE2F163).withOpacity(0.5), // Disabled button color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        minimumSize: Size(screenWidth * 0.85, 50),
      ),
      child: Text(
        'Continue',
        style: GoogleFonts.poppins(
          color: selectedAge > 0 ? const Color(0xFF232323) : Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
}
