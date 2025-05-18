import 'package:flutter/material.dart';
import 'package:balancebite/dbHelper/mongodb.dart';

class ExercisePlan2Screen extends StatefulWidget {
  final Map<String, dynamic> userData;

  // Constructor to accept userData
  ExercisePlan2Screen({required this.userData});

  @override
  _ExercisePlan2ScreenState createState() => _ExercisePlan2ScreenState();
}

class _ExercisePlan2ScreenState extends State<ExercisePlan2Screen> {
  bool isLoading = true;
  List<Map<String, dynamic>> exercisePlan = [];

  @override
  void initState() {
    super.initState();
    fetchExercisePlan();
  }

  // Fetch the exercise plan from MongoDB based on the user's gender, goal, and activity level
  Future<void> fetchExercisePlan() async {
    try {
      final exercises = await MongoDBService.getExercisePlan(widget.userData['_id']); // Use userData to fetch exercise plan
      setState(() {
        exercisePlan = exercises;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching exercise plan: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weekly Exercise Plan'),
        backgroundColor: Color(0xFF74D9EA),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: exercisePlan.length,
              itemBuilder: (context, index) {
                final exercise = exercisePlan[index];
                return ExerciseCard(exercise: exercise);
              },
            ),
    );
  }
}

class ExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;

  ExerciseCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Day: ${exercise['day']}',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF74D9EA),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Exercise: ${exercise['exercisename']}',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Sets: ${exercise['sets']}',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
            Text(
              'Reps/Duration: ${exercise['reps/duration']}',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Calories Burned: ${exercise['calories burned']}',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
