import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For image upload
import 'dart:io'; // For handling file paths
import 'package:balancebite/dbHelper/mongodb.dart'; // Import your MongoDB helper
import 'package:crypto/crypto.dart'; // For password hashing
import 'dart:convert'; // For encoding

class MyProfile extends StatefulWidget {
  final Map<String, dynamic>? userData; // Accept userData as a parameter

  const MyProfile({Key? key, required this.userData}) : super(key: key);

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _bmiController;
  late TextEditingController _passwordController;
  bool _isLoading = true;
  File? _profileImage; // For storing the selected image file
  final ImagePicker _picker = ImagePicker(); // For image picking

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _ageController = TextEditingController();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _bmiController = TextEditingController();
    _passwordController = TextEditingController();
    _initializeProfileData(); // Initialize profile data from userData
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _bmiController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Initialize profile data from userData
  void _initializeProfileData() {
    if (widget.userData != null) {
      setState(() {
        _fullNameController.text = widget.userData!['full_name'];
        _emailController.text = widget.userData!['email'];
        _ageController.text = widget.userData!['age']?.toString() ?? 'Not Selected';
        _weightController.text = widget.userData!['weight']?.toString() ?? 'Not Selected';
        _heightController.text = widget.userData!['height']?.toString() ?? 'Not Selected';
        _calculateBMI(); // Calculate BMI based on fetched height and weight
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Calculate BMI based on weight and height
  void _calculateBMI() {
    final weight = double.tryParse(_weightController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;

    if (weight > 0 && height > 0) {
      final bmi = weight / (height * height);
      _bmiController.text = bmi.toStringAsFixed(2); // Display BMI with 2 decimal places
    } else {
      _bmiController.text = '0.00';
    }
  }

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Hash the password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password); // Convert password to bytes
    final digest = sha256.convert(bytes); // Hash the bytes
    return digest.toString(); // Return the hashed password
  }

  // Update user profile in the database and refresh the UI
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Check if the email already exists
        final emailExists = await MongoDBService.checkEmailExists(_emailController.text);
        if (emailExists && _emailController.text != widget.userData!['email']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email already exists!')),
          );
          return;
        }

        // Hash the password if it's provided
        final hashedPassword = _passwordController.text.isNotEmpty
            ? _hashPassword(_passwordController.text)
            : null;

        final updatedData = {
          'full_name': _fullNameController.text,
          'email': _emailController.text,
          'age': int.tryParse(_ageController.text) ?? 0,
          'weight': double.tryParse(_weightController.text) ?? 0,
          'height': double.tryParse(_heightController.text) ?? 0,
          'bmi': double.tryParse(_bmiController.text) ?? 0, // Update BMI in the database
          if (hashedPassword != null) 'password': hashedPassword, // Update password if provided
          if (_profileImage != null) 'profileImage': _profileImage!.path, // Update profile image if provided
        };

        // Save the updated data to the database
        await MongoDBService.updateUserProfile(widget.userData!['_id'], updatedData);

        // Update the local state with the new data
        setState(() {
          widget.userData!['full_name'] = updatedData['full_name'];
          widget.userData!['email'] = updatedData['email'];
          widget.userData!['age'] = updatedData['age'];
          widget.userData!['weight'] = updatedData['weight'];
          widget.userData!['height'] = updatedData['height'];
          widget.userData!['bmi'] = updatedData['bmi'];
          if (hashedPassword != null) widget.userData!['password'] = hashedPassword;
          if (_profileImage != null) widget.userData!['profileImage'] = _profileImage!.path;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF74D9EA),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF212020), // Set background color
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage, // Allow user to pick an image
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF74D9EA),
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!) // Display selected image
                            : null,
                        child: _profileImage == null
                            ? Text(
                                _fullNameController.text.isNotEmpty
                                    ? _fullNameController.text[0]
                                    : 'M',
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fullNameController,
                      style: const TextStyle(color: Colors.white), // White text
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white), // White text
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageController,
                      style: const TextStyle(color: Colors.white), // White text
                      decoration: InputDecoration(
                        labelText: 'Age',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your age';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _weightController,
                      style: const TextStyle(color: Colors.white), // White text
                      decoration: InputDecoration(
                        labelText: 'Weight (kg)',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _calculateBMI(); // Recalculate BMI when weight changes
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your weight';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _heightController,
                      style: const TextStyle(color: Colors.white), // White text
                      decoration: InputDecoration(
                        labelText: 'Height (m)',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _calculateBMI(); // Recalculate BMI when height changes
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your height';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bmiController,
                      style: const TextStyle(color: Colors.white), // White text
                      decoration: InputDecoration(
                        labelText: 'BMI',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      readOnly: true, // Make BMI field non-editable
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(color: Colors.white), // White text
                      decoration: InputDecoration(
                        labelText: 'Update Password',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      obscureText: true, // Hide password
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF74D9EA),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Update Profile',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}