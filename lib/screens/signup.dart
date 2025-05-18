import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'privacypolicy.dart';
import 'signin.dart'; // Importing SignInPage
import 'gender.dart'; // Importing SignInPage
import 'package:balancebite/dbHelper/mongodb.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Password visibility control
  bool _obscurePassword = true; // For password field
  bool _obscureConfirmPassword = true; // For confirm password field

   @override
  void dispose() {
    // Dispose controllers to free up resources
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      body: SafeArea( // Added SafeArea to prevent content from being cut off
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: 480,
                    minWidth: screenWidth * 0.9,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF232323),
                  ),
                  child: Column(
                    children: [
                      _buildAuthHeader(context),
                      _buildAuthForm(),
                      _buildSocialSignUp(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

Widget _buildAuthHeader(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    alignment: Alignment.center,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align everything to the start (left)
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Image.asset(
            'assets/Arrow2.png', // Replace with the correct path for arrow2.png
            width: 24,
            height: 24,
            semanticLabel: 'Go back',
          ),
        ),
        SizedBox(height: screenHeight * 0.05), // Add some space after the arrow

        // Create Account text (Centered)
        Center(
          child: Text(
            'Create Account',
            style: const TextStyle(
              color: Color(0xFFE2F163),
              fontSize: 24,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.03), // Add some space between texts

        // Let's Start text (Centered)
        Center(
          child: const Text(
            "Let's Start!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildAuthForm() {
    return Container(
      color: const Color(0xFF74D9EA),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormField(
              label: 'Full name',
              hintText: '',
              controller: _nameController,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            _buildFormField(
              label: 'Email',
              hintText: '',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            _buildPasswordField(
              label: 'Password',
              controller: _passwordController,
              isConfirmPassword: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters long';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            _buildPasswordField(
              label: 'Confirm Password',
              controller: null,
              isConfirmPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hintText,
    TextEditingController? controller,
    TextInputType? keyboardType,
    TextInputAction? textInputAction, 
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF232323),
            fontSize: 16,
            fontFamily: 'League Spartan',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.white),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.white),
            ),
          ),
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordField({
  required String label,
  required TextEditingController? controller,
  required bool isConfirmPassword, 
  String? Function(String?)? validator,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Color(0xFF232323),
          fontSize: 16,
          fontFamily: 'League Spartan',
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 7),
      TextFormField(
        controller: controller,
        obscureText: isConfirmPassword ? _obscureConfirmPassword : _obscurePassword,
        decoration: InputDecoration(
          hintText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.white),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              (isConfirmPassword ? _obscureConfirmPassword : _obscurePassword)
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                if (isConfirmPassword) {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                } else {
                  _obscurePassword = !_obscurePassword;
                }
              });
            },
          ),
        ),
        validator: validator,
      ),
    ],
  );
}


  Widget _buildSocialSignUp() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'League Spartan',
                color: Colors.white,
              ),
              children: [
                const TextSpan(text: 'By continuing, you agree to '),
                TextSpan(
                  text: 'Privacy Policy.',
                  style: TextStyle(
                    color: const Color(0xFFE2F163),
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Navigate to PrivacyPolicy screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PrivacyPolicy()),
                  );
                },
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () => _handleSignUp(_formKey, _nameController, _emailController, _passwordController, context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.09),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
                side: const BorderSide(color: Colors.white, width: 0.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            ),
            child: const Text(
              'Sign Up',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 23),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'League Spartan',
                color: Color(0xFFE2F163),
              ),
              children: [
                const TextSpan(
                  text: 'Already have an account? ',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'Log in',
                  style: TextStyle(
                    color: const Color(0xFFE2F163),
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInPage()),
                      );
                    },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _handleSignUp(
  GlobalKey<FormState> formKey,
  TextEditingController nameController,
  TextEditingController emailController,
  TextEditingController passwordController,
  BuildContext context
) async {
  final uuid = Uuid();
  final String userId = uuid.v4();
  
  // Validate the form
  if (formKey.currentState!.validate()) {
    // Collect user data from form fields
    final userData = {
      '_id': userId,  // Automatically generate a unique ObjectId
      'full_name': nameController.text,
      'email': emailController.text,
      'password': hashPassword(passwordController.text), // Hash the password
      'gender': null, // To be added in the next page
      'age': null,
      'weight': null,
      'height': null,
      'bmi': null,
      'goal': null,
      'activity_level': null,
      'profileImage': null,
      'classification': null,
      'ideal_range': null,
    };

    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Check if email already exists
      bool emailExists = await MongoDBService.doesEmailExist(userData['email']!);
      if (emailExists) {
        // Close the loading indicator
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email already exists. Please try another one.')),
        );
        return;
      }

      // Save data to MongoDB
      await MongoDBService.insertUser(userData);
      print('User signed up successfully!');

      // Send confirmation email
      await sendConfirmationEmail(userData['email']!);
      print('Confirmation email sent!');

      // Close the loading indicator
      Navigator.of(context).pop();

      // Navigate to the Gender selection page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GenderSelectionScreen(userData)),
      );
    } catch (e) {
      // Close the loading indicator
      Navigator.of(context).pop();

      // Handle errors and show appropriate messages
      if (e.toString().contains("Email already exists")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email already exists. Please try another one.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign up: $e')),
        );
      }

      print('Error: $e');
    }
  }
}

String hashPassword(String text) {
  // Convert the input text to UTF-8 bytes
  final bytes = utf8.encode(text);

  // Hash the bytes using SHA-256
  final digest = sha256.convert(bytes);

  // Convert the hash to a hexadecimal string and return
  return digest.toString();
}

Future<void> sendConfirmationEmail(String email) async {
  final String smtpServerHost = 'smtp.gmail.com'; // Replace with your SMTP host
  final int smtpServerPort = 587; // Replace with your SMTP port (587 for TLS, 465 for SSL)
  final String username = 'balancebitefyp@gmail.com'; // Replace with your email
  final String password = 'ukmq tijk kxfg ttnd'; // Replace with your email's app-specific password (not your actual password)

  // Create SMTP server configuration
  final smtpServer = SmtpServer(
    smtpServerHost,
    port: smtpServerPort,
    username: username,
    password: password,
    ignoreBadCertificate: false,
    ssl: false, // Use SSL if the port is 465
  );

  // Create the email message
  final message = Message()
    ..from = Address(username, 'BalanceBite') // Replace with sender name
    ..recipients.add(email) // Add recipient's email
    ..subject = 'Welcome to BalanceBite!' // Email subject
    ..text = 'Hello,\n\nThank you for signing up! We are excited to have you on board.\n\nBest regards,\nBalanceBite' // Plain text message
    ..html = '<h1>Welcome to BalanceBite!</h1><p>Thank you for signing up! We are excited to have you on board.</p>'; // HTML message

  try {
    // Send the email
    final sendReport = await send(message, smtpServer);
    print('Email sent: ${sendReport.toString()}');
  } catch (e) {
    print('Error sending email: $e');
    throw Exception('Failed to send confirmation email');
  }
}

