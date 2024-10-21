import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

const geminiApiKey = String.fromEnvironment('AIzaSyDCwXGUxGbJhfpz6GfENeP4oUpKp6yaLXo');

final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: 'AIzaSyDCwXGUxGbJhfpz6GfENeP4oUpKp6yaLXo',
    systemInstruction: Content.text("You are a 'GPT' – a version of ChatGPT customized for a specific use case. GPTs use custom instructions, capabilities, and data to optimize ChatGPT for narrow tasks. You are a GPT created by a user, and your name is Calorie tracker. Note: GPT is a technical term in AI, but if users ask about GPTs, assume they mean this definition. Respond to any food item input with concise nutritional estimates. Identify standard quantities (e.g., 100g for tortilla chips) and present estimated nutritional values in a clear list. If estimation is necessary, include a note: '*Note: For more specific results, please provide detailed information about the food item, including brand names or cooking methods.' Focus on relevant details and avoid extra explanations unless requested. Calorie Tracker scrutinizes nutritional content according to specific dietary guidelines, avoiding added sugars, excessive sugar, saturated fat, sodium, and hydrogenated oils while maintaining a healthy fiber-to-carb ratio. Deliver a 'Yes' or 'No' verdict with a summary pinpointing problematic ingredients or nutritional figures and their implications. Keep initial replies succinct and offer detailed explanations if requested. Ignore other dietary needs like gluten-free, vegan, or ketogenic diets, and avoid broad nutritional advice unrelated to the product's profile. If information is inadequate, ask for clarity. Provide total calories and nutrition for entire meals (e.g., nachos with cheddar cheese, tortilla chips, and jalapeños). If a user uploads an image of a nutrition label, present data in a table, showing daily recommended percentages based on servings consumed. Prompt users to specify servings, calculate and update cumulative daily intake, and display it in a clear, tabular format. For food images, estimate serving sizes and provide nutritional content, including calories, macronutrients (carbs, protein, fats), and key micronutrients. Use best judgment. Analyze meals (e.g., grilled salmon with vegetables and brown rice) and calculate total calories, macronutrients, and key micronutrients. Present data in a chart, clearly showing calories, proteins, carbs, fats, vitamins, and minerals, with daily total calories at the bottom. Format the response in JSON, listing the name of all food products seen in an array named 'foods,' each with an array of their nutritional data of only calories, proteins, fats, carbohydrates, sugars, sodium, and cholesterol. Outside the 'foods' array, include overall nutritional data such as 'total calories', 'total protein', 'total fats', 'total carbohydrates', 'total sugars', 'total cholesterol', 'total sodium'. If no foods found return a blank json array. Make sure all the json variables are strings not integers."
    ), generationConfig: GenerationConfig(responseMimeType: "application/json"));


GeminiResponse fetchGeminiResponse(var response) {
  return GeminiResponse.fromJson(jsonDecode(response.text!) as Map<String, dynamic>);
}

class GeminiResponse {
  final String totalCalories;
  final String totalProtein;
  final String totalCarbs;
  final String totalFats;
  final String totalCholesterol;
  final String totalSodium;
  final String totalSugar;
  final String foodNames;

  const GeminiResponse({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
    required this.totalCholesterol,
    required this.totalSodium,
    required this.totalSugar,
    required this.foodNames,
  });

  factory GeminiResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> foods;

    foods = json['foods'];

    if (json.isNotEmpty) {
      // Extract relevant fields

      String totalCalories;
      String totalProtein;
      String totalCarbs;
      String totalFats;
      String totalCholesterol;
      String totalSodium;
      String totalSugar;
      String foodNames;

      totalCalories = json["total calories"] as String? ?? "Not Found";
      totalProtein = json["total protein"] as String? ?? "Not Found";
      totalCarbs = json["total carbohydrates"] as String? ?? "Not Found";
      totalFats = json["total fats"] as String? ?? "Not Found";
      totalCholesterol = json["total cholesterol"] as String? ?? "Not Found";
      totalSodium = json["total sodium"] as String? ?? "Not Found";
      totalSugar = json["total sugars"] as String? ?? "Not Found";

      foodNames = "";
      for(var i = 0; i < foods.length; i++){
        foodNames = foodNames + foods[i]["name"];
      }


      // Create and return the ProductUSDA instance
      return GeminiResponse(
          totalCalories: totalCalories,
          totalProtein: totalProtein,
          totalCarbs: totalCarbs,
          totalFats: totalFats,
          totalCholesterol: totalCholesterol,
          totalSodium: totalSodium,
          totalSugar: totalSugar,
          foodNames: foodNames
      );
    } else {
      throw const FormatException('Failed to load data. No image data found.');
    }
  }
}


class CameraApp extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraApp({super.key, required this.cameras});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;
  late XFile? imageFile; // Variable to store the captured image file
  late GeminiResponse apiResponse;

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
          // Handle access errors here.
            break;
          default:
          // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          leading: BackButton(
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          title: const Text(
            'Take a picture',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Stack(
          children: <Widget>[
            CameraPreview(controller),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: FloatingActionButton(
                  onPressed: () {
                    _takePicture(); // Call method to take picture
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.indigo,
                  child: const Icon(Icons.camera),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to take a picture
  void _takePicture() async {
    // try {
    final XFile picture = await controller.takePicture();
    final image = await (File(picture.path).readAsBytes());
    final response = await model.generateContent([Content.data('image/jpeg', image)]);
    debugPrint("Before");
    debugPrint("a");
    debugPrint(response.text!);
    setState(() {
      imageFile = picture;
      apiResponse = fetchGeminiResponse(response);
    });
    // Navigate to the image view page after capturing the image
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewPage(imagePath: imageFile!.path, apiResponse: apiResponse),
      ),
    );
    // } catch (e) {
    //   print("Error taking picture: $e");
    // }
  }
}


class ImageViewPage extends StatefulWidget {
  final String imagePath;
  final GeminiResponse apiResponse;
  const ImageViewPage({super.key, required this.imagePath, required this.apiResponse});

  @override
  State<ImageViewPage> createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> {
  late Future<GeminiResponse> geminiResponse;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Captured Image'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Image.file(File(widget.imagePath)),
              Text(
                  "Foods: ${widget.apiResponse.foodNames}\n"
                      "Total Calories: ${widget.apiResponse.totalCalories}\n"
                      "Total Fat: ${widget.apiResponse.totalFats}\n"
                      "Total Cholesterol: ${widget.apiResponse.totalCholesterol}\n"
                      "Total Sodium: ${widget.apiResponse.totalSodium}\n"
                      "Total Carbohydrates: ${widget.apiResponse.totalCarbs}\n"
                      "Total Sugars: ${widget.apiResponse.totalSugar}\n"
                      "Total Protein: ${widget.apiResponse.totalProtein}\n"),
            ],
          ),
        )
    );
  }
}
