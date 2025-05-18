import 'package:balancebite/dbHelper/mongodb.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'goal.dart';

class BMIResultScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const BMIResultScreen(this.userData, {Key? key}) : super(key: key);

  @override
  _BMIResultScreenState createState() => _BMIResultScreenState();
}

class _BMIResultScreenState extends State<BMIResultScreen> {
  double? height;
  double? weight;
  int? age;
  String? gender;
  bool isLoading = false;
  List<Map<String, dynamic>> bmiClassifications = [];
  String classification = 'Unknown';
  String idealRange = 'Unknown';

  @override
  void initState() {
    super.initState();
    print("User data in BMIResultScreen: ${widget.userData}");
    _fetchUserData();
    _fetchBMIClassifications();
  }

  void _fetchUserData() {
    if (widget.userData.isNotEmpty) {
      setState(() {
        height = widget.userData['height']?.toDouble();
        weight = widget.userData['weight']?.toDouble();
        age = widget.userData['age']?.toInt();
        gender = widget.userData['gender'] ?? 'Unknown';
      });
    } else {
      print("User data not found!");
    }
  }

  Future<void> _fetchBMIClassifications() async {
    setState(() => isLoading = true);
    try {
      bmiClassifications = await MongoDBService.getBMIClassifications();
      print("Fetched ${bmiClassifications.length} BMI classifications");
    } catch (e) {
      print('Error fetching BMI classifications: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  double _calculateBMI() {
    if (height != null && weight != null && height! > 0) {
      return weight! / (height! * height!);
    }
    return 0.0;
  }

  String _determineAgeGroup() {
    if (age == null) return 'Unknown';
    if (age! < 5) return '0-5 years';
    if (age! <= 19) return '5-19 years';
    if (age! <= 39) return '20-39 years';
    if (age! <= 59) return '40-59 years';
    return '60+ years';
  }

  void _classifyBMI(double bmi) {
    final ageGroup = _determineAgeGroup();
    final userGender = gender ?? 'Unknown';

    print("Debug: Age Group = $ageGroup, Gender = $userGender, BMI = $bmi");

    final validClassifications = bmiClassifications.where((entry) {
      final entryGender = entry['gender'].toString();
      final entryAgeGroup = entry['ageGroup'].toString();

      print("Debug: Checking entry - Age Group: $entryAgeGroup, Gender: $entryGender");

      return entryAgeGroup == ageGroup && 
            (entryGender == userGender || entryGender == 'Male/Female');
    }).toList();

    print("Debug: Found ${validClassifications.length} valid classifications");
    validClassifications.forEach((c) => print(c));

    for (var category in validClassifications) {
      final range = category['bmiRange'].toString().trim();
      
      try {
        if (range.startsWith('<')) {
          final max = double.parse(range.substring(1));
          if (bmi < max) {
            classification = category['classification'];
            break;
          }
        } else if (range.startsWith('>')) {
          final min = double.parse(range.substring(1));
          if (bmi > min) {
            classification = category['classification'];
            break;
          }
        } else if (range.startsWith('≥')) {
          final min = double.parse(range.substring(1));
          if (bmi >= min) {
            classification = category['classification'];
            break;
          }
        } else if (range.contains('-')) {
          final ranges = range.split('-');
          final min = double.parse(ranges[0]);
          final max = double.parse(ranges[1]);
          if (bmi >= min && bmi <= max) {
            classification = category['classification'];
            break;
          }
        }
      } catch (e) {
        print('Error parsing range $range: $e');
      }
    }

    // Find ideal range
    final normalEntry = validClassifications.firstWhere(
      (c) => c['classification'] == 'Normal',
      orElse: () => {'bmiRange': 'N/A'},
    );
    
    idealRange = normalEntry['bmiRange'].toString();

    print("Debug: Classification = $classification, Ideal Range = $idealRange");
  }

  Future<void> _saveBMIAndNavigate(double bmi, BuildContext context) async {
    try {
      // Save BMI, classification, and ideal range to database
      await MongoDBService.updateUserbmi(
        widget.userData['_id'].toString(), 
        bmi.toStringAsFixed(2),
        classification.toString(),
        idealRange.toString(),
      );

      // Create updated user data with BMI information
      final updatedData = Map<String, dynamic>.from(widget.userData)
        ..['bmi'] = bmi.toString()
        ..['classification'] = classification
        ..['ideal_range'] = idealRange;

      // Navigate to GoalSelectionScreen with updated data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GoalSelectionScreen(userData: updatedData),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save BMI: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF232323),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFE2F163)),
        ),
      );
    }

    if (height == null || weight == null || age == null || gender == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF232323),
        body: Center(
          child: Text(
            "Missing user data!",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    final bmi = _calculateBMI();
    _classifyBMI(bmi);

    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Column(
            children: [
              _buildHeader(context),
              SizedBox(height: screenHeight * 0.03),
              _buildTitleSection(),
              SizedBox(height: screenHeight * 0.05),
              _buildBmiCard(bmi),
              SizedBox(height: screenHeight * 0.06),
              _buildIdealRangeCard(),
              const Spacer(),
              _buildContinueButton(context, bmi),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
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
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          'Body Mass Index',
          style: GoogleFonts.leagueSpartan(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Your BMI classification based on your height and weight',
          textAlign: TextAlign.center,
          style: GoogleFonts.leagueSpartan(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildBmiCard(double bmi) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF74D9EA),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            'Your BMI',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF232323),
            ),
          ),
        ),
        SizedBox(height: 24),
        Text(
          bmi.toStringAsFixed(1),
          style: GoogleFonts.poppins(
            fontSize: 64,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
          decoration: BoxDecoration(
            color: const Color(0xFF74D9EA).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            classification.toUpperCase(),
            style: GoogleFonts.leagueSpartan(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF74D9EA),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIdealRangeCard() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            'Ideal Range',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF232323),
            ),
          ),
        ),
        SizedBox(height: 24),
        Text(
          idealRange,
          style: GoogleFonts.poppins(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context, double bmi) {
    return GestureDetector(
      onTap: () => _saveBMIAndNavigate(bmi, context),
      child: Container(
        width: 199,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFE2F163),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Text(
            'Continue',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}