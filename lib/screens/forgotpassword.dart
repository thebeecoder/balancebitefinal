import 'package:balancebite/dbHelper/mongodb.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPassword extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  Future<Map<String, dynamic>> sendResetEmail(String email) async {
    final url = Uri.parse('http://your-backend.com/send-reset-email');
    final response = await http.post(
      url,
      body: {'email': email},
    );

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: BoxDecoration(
            color: Color(0xFF232323),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 52.0),
                      child: Image.asset(
                        'assets/logobd.png',
                        width: screenWidth * 0.1,
                        height: screenHeight * 0.05,
                      ),
                    ),
                    SizedBox(width: 30),
                    Padding(
                      padding: const EdgeInsets.only(top: 42.0),
                      child: Text(
                        'Forgotten Password',
                        style: TextStyle(
                          color: Color(0xFFE2F163),
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Enter your email address to receive a reset link.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'League Spartan',
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(116, 217, 234, 1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Enter your email address',
                      style: TextStyle(
                        color: Color(0xFF232323),
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'League Spartan',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      style: TextStyle(
                        color: Color(0xFF232323),
                        fontSize: screenWidth * 0.04,
                        fontFamily: 'Poppins',
                      ),
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        hintText: 'example@example.com',
                        hintStyle: TextStyle(
                          color: Color(0xFF232323),
                          textBaseline: TextBaseline.alphabetic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color(0xFF232323), backgroundColor: Color(0xFFE2F163),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                ),
                onPressed: () async {
                  final email = _emailController.text;
                  if (email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter your email address')),
                    );
                    return;
                  }

                  try {
                    print('Checking email: $email'); // Debug print
                    final emailExists = await MongoDBService.checkEmail(email);
                    print('Email exists: $emailExists'); // Debug print
                    if (!emailExists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Email not found')),
                      );
                      return;
                    }

                    await MongoDBService.generateResetToken(email);
                    final user = await MongoDBService.getUserData(email);
                    final token = user!['resetToken'];
                    await MongoDBService.sendResetEmail(email, token);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Reset link sent to your email')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}