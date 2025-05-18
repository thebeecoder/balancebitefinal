import 'package:balancebite/dbHelper/mongodb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import
import 'dart:io';
import 'package:image/image.dart' as img; // For image processing
import 'package:onnxruntime/onnxruntime.dart';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'foodrecognition.dart';

class FoodDetail extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final String imagePath;

  const FoodDetail({Key? key, required this.imagePath, required this.userData}) : super(key: key);

  @override
  _FoodDetailState createState() => _FoodDetailState();
}

class _FoodDetailState extends State<FoodDetail> {
  int servings = 1;
  String selectedFood = 'None';
  Map<String, dynamic> foodInfo = {
    'kcal': 0,
    'fat': 0,
    'carbs': 0,
    'protein': 0,
  };
  List<String> foodOptions = ['---'];
  bool isLoading = true;
  img.Image? fullImage;

  @override
  void initState() {
    super.initState();
    // Initialize foodOptions with 'None' as the default value
    foodOptions = ['None'];
    // Perform food recognition and fetch initial food info
    predictFoodOptions().then((_) {
      if (foodOptions.isNotEmpty && foodOptions[0] != 'None') {
        fetchFoodInfo(foodOptions[0]);
      }
    });
  }

  Future<void> loadFullImage() async {
    try {
      // Load the full camera image
      final imageFile = File(widget.imagePath);
      final compressedFile = await compressImage(imageFile);  
      final imageBytes = await compressedFile.readAsBytes();
      final image = img.decodeImage(imageBytes)!;
      setState(() {
        fullImage = image;
      });
    } catch (e) {
      print('Error loading full image: $e');
    }
  }

  Future<void> predictFoodOptions() async {
    try {
      // Load and compress the image
      final imageFile = File(widget.imagePath);
      final compressedFile = await compressImage(imageFile);
      final imageBytes = await compressedFile.readAsBytes();

      // Send the image to the Python backend for preprocessing
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.171.196:5000/preprocess'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', compressedFile.path));

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        // Parse the response
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);

        // Get the preprocessed data
        final preprocessedData = List<double>.from(jsonResponse['preprocessed_data']);

        // Initialize the ONNX runtime environment
        OrtEnv.instance.init();

        // Load the ONNX model from assets
        const assetFileName = 'assets/model.onnx';
        final rawAssetFile = await rootBundle.load(assetFileName);
        final bytes = rawAssetFile.buffer.asUint8List();

        // Create the ONNX runtime session
        final sessionOptions = OrtSessionOptions();
        final session = OrtSession.fromBuffer(bytes, sessionOptions);

        // Prepare the input tensor with the correct shape
        final inputTensor = OrtValueTensor.createTensorWithDataList(
          Float32List.fromList(preprocessedData),
          [1, 3, 224, 224], // Batch size, channels, height, width
        );

        // Run inference with the correct input name
        final inputs = {'input': inputTensor};
        final runOptions = OrtRunOptions();
        final outputs = await session.run(runOptions, inputs);

        // Extract the output (logits)
        final outputTensor = outputs.first!.value as List<List<double>>;
        
        // Flatten the 2D output tensor to a 1D list
        final flattenedOutput = outputTensor.expand((element) => element).toList();

        // Get the top predictions
        final topPredictions = getTopPredictions(flattenedOutput, 4); // Get top 4 predictions

        // Update the food options in the UI
        setState(() {
          foodOptions = topPredictions.isNotEmpty ? topPredictions : ['None'];
          selectedFood = foodOptions[0];
          isLoading = false;
        });

        // Clean up
        inputTensor.release();
        runOptions.release();
        for (var tensor in outputs) {
          tensor!.release();
        }
        session.release();
        OrtEnv.instance.release();
      } else {
        print('Failed to preprocess image: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error during prediction: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Preprocess the image (normalize and convert to a flat list)
  Float32List preprocessImage(img.Image image) {

    final inputData = Float32List(224 * 224 * 3); // 224x224x3 for RGB channels
    int index = 0;

    // Resize the image to 224x224
    final img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

    // Iterate over the resized image
  for (var y = 0; y < resizedImage.height; y++) {
    for (var x = 0; x < resizedImage.width; x++) {
      final pixel = resizedImage.getPixel(x, y);
      inputData[index++] = (pixel.r / 255.0 - 0.485) / 0.229; // Normalize R
      inputData[index++] = (pixel.g / 255.0 - 0.456) / 0.224; // Normalize G
      inputData[index++] = (pixel.b / 255.0 - 0.406) / 0.225; // Normalize B
    }
  }
    return inputData;
  }

  // Get the top N predictions from the output tensor
  List<String> getTopPredictions(List<double> outputTensor, int topN) {
    // Map the output tensor indices to food labels
    final foodLabels = [
      'Afghani Pulao', 'Almond Milk', 'Aloo Curry', 'Aloo Gosht', 'Aloo Bukhara', 'Alucha', 'Amlok', 
      'Amrood', 'Anar', 'Apple', 'Apricot', 'Banana', 'Banana Shake', 'Beef Burger', 'Beef Korma', 
      'Besan Ladoo', 'Black Berry', 'Carbonated Beverages', 'Chana Daal With Ghee Tarka', 'Chapli Kabab', 
      'Cheese Ball', 'Cheese Garlic Bread', 'Chicken Burger', 'Chicken Malai Boti', 'Chicken Nuggets', 
      'Chicken Sajji With Rice', 'Chicken Shawarma', 'Chicken Strips', 'Chicken Wings', 'Chinese Hotpot', 
      'Chocolate Custard', 'Club Sandwich', 'Coconut Ladoo', 'Coffee Cappucinno', 'Coffee Espresso', 
      'Coffee Iced Latte', 'Coffee Latte', 'Custard', 'Dates', 'Doodh Jalebi', 'Doodh Patti', 
      'Egg Custard', 'Falsa', 'Falsa Juice', 'Fried Rice', 'Fruit Custard', 'Fruit Smoothie', 
      'Gosht', 'Grapes', 'Green Tea', 'Jamun', 'Kalay Chanay', 'Kashmiri Chai', 'Kinno', 
      'Lahori Fried Fish', 'Lasagna With Chicken', 'Lasagna With Meat', 'Lassi', 'Lemon', 
      'Lemon Juice', 'Loaded Fries', 'Low-Fat Custard', 'Lukhnowi Korma', 'Lychee', 'Macaroni', 
      'Malta', 'Mango Juice', 'Mango Ripe', 'Milk Cake', 'Mutton Pulao', 'Naan', 'Narangi', 
      'Nashpati', 'Noodles', 'Papita', 'Paratha Shawarma', 'Pasta', 'Peshawari Karahi', 'Pineapple', 
      'Pizza', 'Protein Shake', 'Rabri', 'Rasgulla', 'Rooh Afza', 'Rusmalai', 'Sajji', 'Sarda', 
      'Shikarpuri Achar', 'Sindhi Kadhi', 'Spaghetti', 'Stawberry', 'Tarbuz', 'Tikka Kabab', 
      'Vanilla Custard', 'Vegetable Jalfrezi', 'Zinger Burger', 'Achari Chicken', 'Akhrot', 
      'Aloo Capsicum', 'Aloo Chaat', 'Aloo Gawar Phali', 'Aloo Gobhi', 'Aloo Ki Bhujia', 
      'Aloo Matar', 'Aloo Methi', 'Aloo Mungray', 'Aloo Paratha', 'Aloo Qeema', 'Aloo Tikki', 
      'Aloo Turai', 'Anda Bhurji', 'Anda Chana', 'Anday Ka Halwa', 'Anday Wala Burger', 'Arbi Sabzi', 'Badam', 'Baingan Ka Bharta', 'Banana Kheer', 'Barfi', 'Beef Chili Dry', 'Besan Ka Halwa', 'Bhel Puri', 'Bhindi', 'Bhuna Gosht', 'Bihari Kabab', 'Biryani', 'Biscuit', 'Boiled Egg', 'Bun Kebab', 'Butter Chicken', 'Chana Daal Halwa', 'Chana Masala', 'Chana_Puri', 'Chapati', 'Chicken Cheese Omelette', 'Chicken Chungay', 'Chicken Ginger Curry', 'Chicken Handi', 'Chicken Patties', 'Chicken Sandwiches', 'Chicken Shashlik', 'Chicken Yakhni Soup', 'Chilgoza', 'Chinese Spring Rolls', 'Chow Mein', 'Crab', 'Curry Pakora', 'Daal Chawal', 'Daal Gosht', 'Daal Mash', 'Dahi Baingan', 'Dahi Bhalla', 'Dahi Papri Chaat', 'Dahi Puri', 'Desi Murgh', 'Dhokla', 'Donuts', 'Double Roti', 'Dum Arbi', 'Dum Pukht', 'Dumplings', 'Egg Fried', 'Fafda', 'Falooda', 'Feerni', 'Fish (Khaga)', 'Fish (Promfret)', 'Fish (Roa)', 'Fish (Shanghara)', 'Fish (Soal)', 'Fish (Surmai)', 'Fish Biryani', 'Fish Karahi', 'Fish Pakora', 'Fish Tikka', 'French Toast', 'Fried Aloo', 'Fried Chicken Wings', 'Fried Fish', 'Gobi Manchurian', 'Gobi Paratha', 'Gol Gappay', 'Gola Kabab', 'Gur Wala Parathay', 'Haleem', 'Halwa Gajjar', 'Halwa Puri', 'Halwa Suji', 'Hot And Sour Soup', 'Icecream', 'Idli', 'Jalebi With Rabri', 'Jaleebi', 'Jau Ki Roti', 'Kachori With Chutney', 'Kaddu Ka Halwa', 'Kaju', 'Kaju Katli', 'Karahi', 'Karela Gosht', 'Kat A Kat', 'Keema', 'Keema Paratha', 'Kheer', 'Khopra', 'Khow Suey', 'Khoya', 'Kichri', 'Kofta', 'Kulcha', 'Kulfi', 'Kung Pao Beef', 'Lab E Shireen', 'Lachha Paratha', 'Lahori Chargha', 'Lemon Chicken', 'Lobia', 'Makki Roti', 'Malai Boti', 'Masoor Dal', 'Matar', 'Matar Paneer', 'Mathri', 'Methi Chicken', 'Mint Raita', 'Mithai', 'Mix Sabzi', 'Mooli Paratha', 'Muffin', 'Murgh Makhni', 'Mutton Chops Masala', 'Mutton Handi', 'Namak Paray', 'Nihari', 'Ojri', 'Omelette', 'Pakoras', 'Palak Gosht', 'Palak Paneer', 'Pancakes', 'Paratha', 'Paratha Rolls', 'Paya', 'Peshawari Chapli Kebab', 'Pista', 'Prawn', 'Prawn Karahi', 'Pulao', 'Qorma', 'Raan Roast', 'Raita', 'Rajma Chawal', 'Roghni Naan', 'Saag Paneera', 'Samosa', 'Samosa Chaat', 'Sarson Ka Saag', 'Seekh Kabab', 'Seviyan', 'Shalgam Ki Sabzi', 'Shami Kabab', 'Sheer Khurma', 'Sheermal', 'Sindhi Biryani', 'Siri Paye', 'Sohan Halwa', 'Sonf', 'Soup', 'Supari', 'Sweet And Sour Chicken', 'Tandoori Chicken', 'Tandoori Chicken Wraps', 'Tandoori Fish', 'Tandoori Roti', 'Tikka Boti', 'Tinda Sabzi', 'Trifle', 'Upma', 'Vegetable Pakora', 'Vegetable Spring Rolls', 'White Dalia', 'White Karahi', 'Yogurt', 'Zarda'
    ];

    // Get the indices of the top N predictions
    final sortedIndices = List<int>.generate(outputTensor.length, (i) => i)
      ..sort((a, b) => outputTensor[b].compareTo(outputTensor[a]));

    // Map indices to food labels
    return sortedIndices.take(topN).map((index) => foodLabels[index]).toList();
  }

  Future<void> fetchFoodInfo(String foodName) async {
    try {
      final data = await MongoDBService.fetchFoodInfo(foodName);
      setState(() {
        foodInfo = {
          'kcal': data['kcal'],
          'fat': data['fat'],
          'carbs': data['carbs'],
          'protein': data['protein'],
        };
      });
    } catch (e) {
      print('Error fetching food info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212020),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        title: const Text('Food Detail'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display the selected/captured image
                    Image.file(
                      File(widget.imagePath),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 20),

                    // Food name
                    Text(
                      selectedFood,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Calories and servings
                    Row(
                      children: [
                        Text(
                          '${foodInfo['kcal'] * servings} KCal',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              if (servings > 1) servings--;
                            });
                          },
                        ),
                        Text(
                          '$servings',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              servings++;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Dropdown for food selection
                    DropdownButton<String>(
                      value: selectedFood,
                      items: foodOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedFood = newValue!;
                        });
                        fetchFoodInfo(selectedFood);
                      },
                      dropdownColor: const Color(0xFF212020),
                    ),
                    const SizedBox(height: 20),

                    // Nutritional Information
                    const Text(
                      'Nutritional Information',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // KCal, Fat, Carbs, Protein
                    _buildNutritionalInfo('KCal', '${foodInfo['kcal'] * servings}'),
                    _buildNutritionalInfo('Fat', '${foodInfo['fat'] * servings}g'),
                    _buildNutritionalInfo('Carbs', '${foodInfo['carbs'] * servings}g'),
                    _buildNutritionalInfo('Protein', '${foodInfo['protein'] * servings}g'),
                    const SizedBox(height: 20),

                    // Add to Food Diary button
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            // Prepare the food details
                            final foodDetails = {
                              'foodName': selectedFood,
                              'servings': servings,
                              'kcal': foodInfo['kcal'] * servings,
                              'fat': foodInfo['fat'] * servings,
                              'carbs': foodInfo['carbs'] * servings,
                              'protein': foodInfo['protein'] * servings,
                            };

                            // Get the image file
                            final imageFile = File(widget.imagePath);

                            // Get the userId from the userData passed to the widget
                            final userId = widget.userData?['_id'];

                            if (userId == null) {
                              throw Exception('User ID or email not found in userData');
                            }

                            // Add the food details to the diary
                            await MongoDBService.addFoodToDiary(userId, foodDetails, imageFile);

                            // Show a success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to food diary')),
                            );

                            // Navigate to FoodRecognition screen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FoodRecognition(userData: widget.userData),
                              ),
                            );
                          } catch (e) {
                            // Show an error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to add food to diary: $e')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF74D9EA),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        ),
                        child: const Text(
                          'Add to Food Diary',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper method to build nutritional info row
  Widget _buildNutritionalInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Future<File> compressImage(File file) async {
    // Create a temporary file path for the compressed image
    final tempDir = Directory.systemTemp; // Get the system's temp directory
    final tempFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');

    // Compress the image and save it to the temporary file
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, // Source path
      tempFile.absolute.path, // Target path (different from source)
      quality: 50, // Adjust quality as needed
    );

    if (result == null) {
      throw Exception('Failed to compress image');
    }

    return File(result.path);
  }
}