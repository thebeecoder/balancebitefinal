import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:balancebite/dbHelper/mongodb.dart';
import 'height.dart';

class WeightSelectorScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const WeightSelectorScreen(this.userData, {Key? key}) : super(key: key);

  @override
  _WeightSelectorScreenState createState() => _WeightSelectorScreenState();
}

class _WeightSelectorScreenState extends State<WeightSelectorScreen> {
  double selectedWeight = 60.0;
  bool isLoading = false;
  bool isWeightSelected = false;

  Future<void> _updateWeight() async {
    setState(() => isLoading = true);
    try {
      await MongoDBService.updateUserweight(
        widget.userData['_id'],
        selectedWeight.toStringAsFixed(1),
      );
      print('Weight updated successfully');

      // Create a COPY of userData and add weight
      Map<String, dynamic> updatedData = Map.from(widget.userData);
      updatedData['weight'] = selectedWeight; // Key must match your database

      print("Updated UserData (Weight): $updatedData"); // Verify data

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HeightSelectorScreen(updatedData),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFF232323)),
        child: Column(
          children: [
            _buildHeader(context, width),
            _buildTitleSection(width),
            _buildWeightDisplay(),
            _buildNumberPicker(),
            const Spacer(),
            _buildContinueButton(),
            SizedBox(height: height * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double width) {
    return Padding(
      padding: EdgeInsets.only(top: 60, left: width * 0.08, right: width * 0.08),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                Image.asset('assets/Arrow2.png', width: 16, height: 16),
                const SizedBox(width: 8),
                Text(
                  'Back',
                  style: GoogleFonts.leagueSpartan(
                    color: const Color(0xFFE2F163),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.08, vertical: 24),
      child: Column(
        children: [
          Text(
            'What Is Your Weight?',
            style: GoogleFonts.leagueSpartan(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Please select your weight to personalize your experience.',
            textAlign: TextAlign.center,
            style: GoogleFonts.leagueSpartan(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightDisplay() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            selectedWeight.toStringAsFixed(0),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'kg',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.6),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberPicker() {
    final numbers = List.generate(150, (index) => 15 + index);
    final centerIndex = numbers.indexOf(selectedWeight.toInt());
    
    return SizedBox(
      height: 200,
      child: ListWheelScrollView(
        itemExtent: 70,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) => setState(() {
          selectedWeight = numbers[index].toDouble();
          isWeightSelected = true;
        }),
        children: numbers.map((number) {
          final isSelected = number == selectedWeight.toInt();
          return Text(
            number.toString(),
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
              fontSize: isSelected ? 40 : 24,
              fontWeight: FontWeight.w600,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContinueButton() {
    return GestureDetector(
      onTap: (isLoading || !isWeightSelected) ? null : _updateWeight, 
      child: Container(
        width: 199,
        height: 44,
        decoration: BoxDecoration(
          color: (isLoading || !isWeightSelected) ? Colors.grey : const Color(0xFFE2F163),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(color: Color(0xFF232323))
              : Text(
                  'Continue',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF232323),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}