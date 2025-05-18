import 'package:flutter/material.dart';
import 'package:balancebite/dbHelper/mongodb.dart';
import 'screens/launch_page.dart'; // Import the LaunchPage
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Add dotenv

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables
    await dotenv.load(fileName: ".env");
  // Connect to MongoDB
  await MongoDBService.connectToDatabase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BalanceBite',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LaunchPage (), // Set LaunchPage as the initial page
    );
  }
}
