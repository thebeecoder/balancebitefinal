import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:balancebite/dbHelper/mongodb.dart';
import 'activity.dart';
import 'age.dart';
import 'gender.dart';
import 'goal.dart';
import 'height.dart';
import 'signup.dart';
import 'onboarding4.dart';
import 'forgotpassword.dart';
import 'home.dart';
import 'package:realm/realm.dart';
import 'weight.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
  if (_formKey.currentState?.validate() ?? false) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Check for connectivity
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet connection')),
      );
      return;
    }

    try {
  // Initialize app configuration with the correct App ID
  final app = App(AppConfiguration('balancebiteapp-ypqajni'));
  final credentials = Credentials.emailPassword(email, password);
  try {
  final user = await app.logIn(credentials);
  print('Logged in: ${user.id}');
} catch (e) {
  print('Login error: $e');
}

  // Ensure MongoDB is properly initialized and open
  if (app.currentUser == null) {
    throw Exception('User is not authenticated');
  }

  // Proceed to fetch user data from MongoDB
  final userData = await MongoDBService.getUserData(email);

  if (userData == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User data not found')),
    );
    return;
  }

      // Navigation logic based on user data
      if (userData['gender'] == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GenderSelectionScreen(userData),
          ),
        );
      } else if (userData['age'] == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AgeSelectorScreen(userData),
          ),
        );
      } else if (userData['weight'] == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WeightSelectorScreen(userData),
          ),
        );
      } else if (userData['height'] == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HeightSelectorScreen(userData),
          ),
        );
      } else if (userData['goal'] == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GoalSelectionScreen(userData: userData),
          ),
        );
      } else if (userData['activity_level'] == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PhysicalActivityScreen(userData: userData),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NutritionDashboard(userData),
          ),
        );
      }
    } on AppException catch (e) {
      // Debugging log for login failure
      print('Login failed with error: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      // Catch any other errors
      print('Error: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.1,
                horizontal: screenWidth * 0.05,
              ),
              child: Center(
                child: Container(
                  width: screenWidth * 0.9,
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OnboardingScreen4(),
                              ),
                            );
                          },
                          child: Image.asset(
                            'assets/Arrow2.png',
                            width: 24,
                            height: 24,
                            semanticLabel: 'Back',
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            'Log In',
                            style: TextStyle(
                              color: const Color(0xFFE2F163),
                              fontSize: 24,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          Text(
                            'Welcome',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            'Track your meals and activities with BalanceBite to easily monitor calories and receive personalized health recommendations. Stay on top of your goals with smart insights!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'League Spartan',
                              fontWeight: FontWeight.w300,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF74D9EA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Username or email',
                                style: TextStyle(
                                  fontFamily: 'League Spartan',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF232323),
                                ),
                              ),
                              SizedBox(height: 7),
                              TextFormField(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  hintText: '',
                                ),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(_passwordFocus);
                                },
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter your email';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Password',
                                style: TextStyle(
                                  fontFamily: 'League Spartan',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF232323),
                                ),
                              ),
                              SizedBox(height: 7),
                              TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      semanticLabel: _obscurePassword
                                          ? 'Show password'
                                          : 'Hide password',
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ForgotPassword(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF232323),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.09),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                                side: const BorderSide(
                                    color: Colors.white, width: 0.5),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 32),
                            ),
                            child: Text(
                              'Log In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'League Spartan',
                                fontWeight: FontWeight.w300,
                              ),
                              children: [
                                TextSpan(
                                  text: "Don't have an account? ",
                                  style: TextStyle(color: Colors.white),
                                ),
                                TextSpan(
                                  text: 'Sign Up',
                                  style: TextStyle(color: Color(0xFFE2F163)),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SignUpPage(),
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}