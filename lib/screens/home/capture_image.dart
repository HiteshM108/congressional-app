import 'dart:io';

import 'package:Nutritrack/screens/home/home.dart';
import 'package:Nutritrack/screens/home/not_a_food.dart';
import 'package:Nutritrack/screens/home/scan.dart';
import 'package:Nutritrack/services/database.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'feed.dart';

import 'dart:async';
import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

const geminiApiKey =
    String.fromEnvironment('AIzaSyDCwXGUxGbJhfpz6GfENeP4oUpKp6yaLXo');

final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: 'AIzaSyDCwXGUxGbJhfpz6GfENeP4oUpKp6yaLXo',
    systemInstruction: Content.text(
        "You are a 'GPT' – a version of ChatGPT customized for a specific use case. GPTs use custom instructions, capabilities, and data to optimize ChatGPT for narrow tasks. You are a GPT created by a user, and your name is Calorie tracker. Note: GPT is a technical term in AI, but if users ask about GPTs, assume they mean this definition. Respond to any food item input with concise nutritional estimates. Identify standard quantities (e.g., 100g for tortilla chips) and present estimated nutritional values in a clear list. If estimation is necessary, include a note: '*Note: For more specific results, please provide detailed information about the food item, including brand names or cooking methods.' Focus on relevant details and avoid extra explanations unless requested. Calorie Tracker scrutinizes nutritional content according to specific dietary guidelines, avoiding added sugars, excessive sugar, saturated fat, sodium, and hydrogenated oils while maintaining a healthy fiber-to-carb ratio. Deliver a 'Yes' or 'No' verdict with a summary pinpointing problematic ingredients or nutritional figures and their implications. Keep initial replies succinct and offer detailed explanations if requested. Ignore other dietary needs like gluten-free, vegan, or ketogenic diets, and avoid broad nutritional advice unrelated to the product's profile. If information is inadequate, ask for clarity. Provide total calories and nutrition for entire meals (e.g., nachos with cheddar cheese, tortilla chips, and jalapeños). If a user uploads an image of a nutrition label, present data in a table, showing daily recommended percentages based on servings consumed. Prompt users to specify servings, calculate and update cumulative daily intake, and display it in a clear, tabular format. For food images, estimate serving sizes and provide nutritional content, including calories, macronutrients (carbs, protein, fats), and key micronutrients. Use best judgment. Analyze meals (e.g., grilled salmon with vegetables and brown rice) and calculate total calories, macronutrients, and key micronutrients, remember to taken account portion sizes for example, display half the calories of a full burger if half the burger is eaten. Present data in a chart, clearly showing calories, proteins, carbs, fats, vitamins, and minerals, with daily total calories at the bottom. Format the response in JSON, listing the name of all food products seen in an array named 'foods,' each with an array of their nutritional data of only calories in kJ, proteins in g, fats in g, fibers in g, sugars in g, sodium in mg, and cholesterol in g. Outside the 'foods' array, include overall nutritional data such as 'total calories', 'total protein', 'total fats', 'total fibers', 'total sugars', 'total cholesterol', 'total sodium'. If no foods found return a blank json array that is '{'foods': []}'. Make sure all the json variables are strings not integers."),
    generationConfig: GenerationConfig(responseMimeType: "application/json"));

final feedbackModel = GenerativeModel(
    model: 'gemini-1.5-flash',
    systemInstruction: Content.text(
        "For context, you are integrated into an app designed to help people determine what they should be eating. You will be given background information about the person. The person will scan a given product and the product will be then told to you and you are to give advice about the product based on the person's background information. The information you will provide is not to be like a conversation but just information. Structure your response to have a first a short paragraph on the overview of the product, then a paragraph about considerations, and then lastly a paragraph on alternatives"),
    apiKey: 'AIzaSyDCwXGUxGbJhfpz6GfENeP4oUpKp6yaLXo');

GeminiResponse fetchGeminiResponse(var response) {
  return GeminiResponse.fromJson(
      jsonDecode(response.text!) as Map<String, dynamic>);
}

var imagePath = "";

class GeminiResponse {
  final String totalCalories;
  final String totalProtein;
  final String totalFibers;
  final String totalFats;
  final String totalCholesterol;
  final String totalSodium;
  final String totalSugar;
  final String foodNames;
  final String nutriscore;

  const GeminiResponse({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalFibers,
    required this.totalFats,
    required this.totalCholesterol,
    required this.totalSodium,
    required this.totalSugar,
    required this.foodNames,
    required this.nutriscore,
  });

  factory GeminiResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> foods;

    foods = json['foods'];

    if (json.isNotEmpty) {
      // Extract relevant fields

      var totalCalories;
      var totalProtein;
      var totalFibers;
      var totalFats;
      var totalCholesterol;
      var totalSodium;
      var totalSugar;
      var nutriscore;
      String foodNames;

      totalCalories = json["total calories"] as String? ?? "Not Found";
      totalProtein = json["total protein"] as String? ?? "Not Found";
      totalFibers = json["total fibers"] as String? ?? "Not Found";
      totalFats = json["total fats"] as String? ?? "Not Found";
      totalCholesterol = json["total cholesterol"] as String? ?? "Not Found";
      totalSodium = json["total sodium"] as String? ?? "Not Found";
      totalSugar = json["total sugars"] as String? ?? "Not Found";

      foodNames = "";
      for (var i = 0; i < foods.length; i++) {
        foodNames = foodNames + foods[i]["name"];
      }

      nutriscore = calculateNutriScore(double.parse(totalCalories),
          double.parse(totalSugar), double.parse(totalFats),
          double.parse(totalSodium), double.parse(totalFibers), double.parse(totalProtein));

      // Create and return the ProductUSDA instance
      return GeminiResponse(
          totalCalories: totalCalories,
          totalProtein: totalProtein,
          totalFibers: totalFibers,
          totalFats: totalFats,
          totalCholesterol: totalCholesterol,
          totalSodium: totalSodium,
          totalSugar: totalSugar,
          foodNames: foodNames,
          nutriscore: nutriscore
      );
    } else {
      throw const FormatException('Failed to load data. No image data found.');
    }
  }
}

class CaptureImage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CaptureImage({super.key, required this.cameras});

  @override
  State<CaptureImage> createState() => _CaptureImageState();
}

class _CaptureImageState extends State<CaptureImage> {
  late CameraController controller;
  late XFile? imageFile; // Variable to store the captured image file
  late GeminiResponse apiResponse;
  late bool isValid;

  double zoomLevel = 1.0;
  double prevZoomLevel = 1.0;
  double minZoomLevel = 1.0;
  double maxZoomLevel = 8.0;

  @override
  void initState() {
    super.initState();

    controller = CameraController(widget.cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) async {
      if (!mounted) {
        return;
      }
      final double minZoom = await controller.getMinZoomLevel();
      final double maxZoom = await controller.getMaxZoomLevel();

      setState(() {
        minZoomLevel = minZoom;
        maxZoomLevel = maxZoom;
      });
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

    return Container(
      child: Stack(
        children: <Widget>[
          Center(
              child: CameraPreview(
            controller,
            child: GestureDetector(
              onScaleStart: (one) {
                prevZoomLevel = zoomLevel;
                setState(() {});
              },
              onScaleUpdate: (one) {
                zoomLevel = prevZoomLevel * one.scale;

                setState(() {
                  controller.setZoomLevel(
                      zoomLevel.clamp(minZoomLevel, maxZoomLevel));
                });
              },
              onScaleEnd: (one) {
                prevZoomLevel = 1.0;
                setState(() {
                  controller.setZoomLevel(
                      zoomLevel.clamp(minZoomLevel, maxZoomLevel));
                });
              },
            ),
          )),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FloatingActionButton(
                onPressed: () {
                  _takePicture(); // Call method to take picture
                },
                child: Icon(MdiIcons.fromString("camera-outline")),
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to take a picture
  void _takePicture() async {
    try {
      final XFile picture = await controller.takePicture();
      final image = await (File(picture.path).readAsBytes());
      setState(() {
        imageFile = picture;
      });
      // Navigate to the image view page after capturing the image

      Navigator.pop(context, picture.path);
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => ImageViewPage(imagePath: imageFile!.path),
      //   ),
      // );
    } catch (e) {
      print("Error taking picture: $e");
    }
  }
}


Future<String> getImageFeedback(String itemName) async {
  String uid = FirebaseAuth.instance.currentUser!.uid;

  var data = DatabaseService(uid: uid).getUserData();

  String geminiResponse = "";

  await for (dynamic field in data) {
    print(field.name);
    print(field.gender);
    print(field.age);
    print(field.height);
    print(field.weight);
    print(field.activityLevel);
    print(itemName);

    geminiResponse = (await feedbackModel.generateContent([
      Content.text(
          "Provide personalized feedback on this food item based on this person's description and goals. The person is a ${field.gender} aged ${field.age} years old whose exercise level is ${field.activityLevel}. The person is ${field.height} inches tall and weighs ${field.weight} pounds. The person is looking to eat a ${itemName}")
    ]))
        .text!;

    break;
  }

  return geminiResponse;
}

class ImageViewPage extends StatefulWidget {
  const ImageViewPage({super.key});

  @override
  State<ImageViewPage> createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> {
  late GeminiResponse apiResponse;
  late Future<String> futureFeedback;
  bool isLoading = false;
  bool isValid = false;

  final Completer<String> feedbackCompleter = Completer();

  @override
  void initState() {
    super.initState();
    futureFeedback = feedbackCompleter.future;
    fetchResponse();
  }

  void fetchResponse() async {

    setState(() {
      isLoading = true;
    });

    try {
      final image = await (File(imagePath).readAsBytes());

      final response = await model
          .generateContent([Content.data('image/jpeg', image)]).timeout(
              const Duration(seconds: 12));


      setState(() async {
        isLoading =
            false; // Disable loading spinner once the response is fetched
        apiResponse = fetchGeminiResponse(response);
        isValid = apiResponse.totalCalories != "Not Found";

        if (!isValid) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => NotAFood(imagePath)));
        } else {
          print(apiResponse.foodNames);
          var geminiResponse = await getImageFeedback(apiResponse.foodNames);
          feedbackCompleter.complete(geminiResponse);
        }
      });
    } on TimeoutException catch (_) {
      setState(() {
        isLoading = false;
        isValid = false;
      });
      showRetryDialog();
    } catch (e) {
      setState(() {
        isLoading = false;
        isValid = false;
      });
      print("Error fetching response: $e");
    }
  }

  void showRetryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Timeout"),
          content: const Text(
              "It took too long to process the image. Please retake the picture."),
          actions: <Widget>[
            TextButton(
              child: const Text("Retake"),
              onPressed: () {
                Navigator.pop(context); // Go back to the camera screen
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var feedbackStore = "";
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        child: SingleChildScrollView(
          child: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Stack(
                  children: [
                    Center(
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * .5,
                        height: MediaQuery.sizeOf(context).width * .5,
                        decoration: BoxDecoration(
                            border: const Border.fromBorderSide(
                                BorderSide(color: Colors.amber, width: 2)),
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.grey[200]),
                        child: Image.file(File(imagePath)),
                      ),
                    ),
                    Positioned(
                      top: 1,
                      left: 1,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => Home()));
                        },
                        child: Icon(MdiIcons.fromString("window-close")),
                        style: ElevatedButton.styleFrom(
                          // styling the button
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(10),
                          foregroundColor: Colors.red,
                          backgroundColor: Colors.grey[200],
                          iconColor: Colors.red,
                          elevation: 2.0,
                          // backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10,),

                Divider(color: Colors.greenAccent, height: 1.0,),

                SizedBox(height: 20,),

                Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(toBeginningOfSentenceCase(apiResponse.foodNames), textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),

                SizedBox(height: 20,),

                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.greenAccent
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  width: MediaQuery.sizeOf(context).width*.5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Nutriscore", textAlign: TextAlign.left, style: Theme.of(context).textTheme.titleMedium,),
                      Text(apiResponse.nutriscore, style: Theme.of(context).textTheme.labelLarge,),
                    ],
                  ),
                ),

                SizedBox(height: 20,),

                Divider(color: Colors.greenAccent, height: 1.0,),

                SizedBox(height: 20,),

                Container(
                  child: Text("Nutrition Advisor", textAlign: TextAlign.left, style: Theme.of(context).textTheme.titleMedium,),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.greenAccent, width: 1.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                ),

                SizedBox(height: 10,),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.grey, width: 2.0),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 35, height: 35,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.greenAccent
                      ),
                      child: Icon(MdiIcons.fromString("spoon-sugar")),
                    ),
                    title: Text("Energy", style: Theme.of(context).textTheme.titleMedium,),
                    trailing: Container(
                      child: Text("${apiResponse.totalCalories} kJ", style: Theme.of(context).textTheme.bodyMedium,),
                    ),
                  ),
                ),
                SizedBox(height: 5,),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.grey, width: 2.0),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 35, height: 35,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.greenAccent
                      ),
                      child: Icon(MdiIcons.fromString("spoon-sugar")),
                    ),
                    title: Text("Sugars", style: Theme.of(context).textTheme.titleMedium,),
                    trailing: Container(
                      child: Text("${apiResponse.totalSugar} g", style: Theme.of(context).textTheme.bodyMedium,),
                    ),
                  ),
                ),
                SizedBox(height: 5,),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.grey, width: 2.0),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 35, height: 35,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.greenAccent
                      ),
                      child: Icon(MdiIcons.fromString("water-outline")),
                    ),
                    title: Text("Saturated Fats", style: Theme.of(context).textTheme.titleMedium,),
                    trailing: Container(
                      child: Text("${apiResponse.totalFats} g", style: Theme.of(context).textTheme.bodyMedium,),
                    ),
                  ),
                ),
                SizedBox(height: 5,),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.grey, width: 2.0),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 35, height: 35,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.greenAccent
                      ),
                      child: Icon(MdiIcons.fromString("shaker-outline")),
                    ),
                    title: Text("Sodium", style: Theme.of(context).textTheme.titleMedium,),
                    trailing: Container(
                      child: Text("${apiResponse.totalSodium} mg", style: Theme.of(context).textTheme.bodyMedium,),
                    ),
                  ),
                ),
                SizedBox(height: 5,),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.grey, width: 2.0),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 35, height: 35,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.greenAccent
                      ),
                      child: Icon(MdiIcons.fromString("barley")),
                    ),
                    title: Text("Fiber", style: Theme.of(context).textTheme.titleMedium,),
                    trailing: Container(
                      child: Text("${apiResponse.totalFibers} g", style: Theme.of(context).textTheme.bodyMedium,),
                    ),
                  ),
                ),
                SizedBox(height: 5,),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.grey, width: 2.0),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 35, height: 35,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.greenAccent
                      ),
                      child: Icon(MdiIcons.fromString("food-drumstick-outline")),
                    ),
                    title: Text("Protein", style: Theme.of(context).textTheme.titleMedium,),
                    trailing: Container(
                      child: Text("${apiResponse.totalProtein} g", style: Theme.of(context).textTheme.bodyMedium,),
                    ),
                  ),
                ),

                SizedBox(height: 20,),

                Divider(color: Colors.greenAccent, height: 1.0,),

                FutureBuilder(
                  future: futureFeedback,
                  builder: (context, snapshot) {
                    var feedback = "";
                    if (snapshot.hasData) {
                      feedback = snapshot.data!;
                      feedbackStore = feedback;
                    }
                    print(feedback);
                    var sections = feedback.split("\n");

                    return feedback != "" ? Column(
                      children: [

                        SizedBox(
                          height: 20,
                        ),

                        Container(
                          child: Text(
                            "Personalized Feedback",
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border:
                            Border.all(color: Colors.greenAccent, width: 1.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 10.0),
                        ),

                        SizedBox(
                          height: 15,
                        ),

                        Container(
                          child: DefaultTabController(
                            length: 3, // Number of tabs
                            child: Container(
                              color: Colors.grey[200],
                              // Background color of the container
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  // TabBar for navigation between sections
                                  TabBar(
                                    labelColor: Colors.greenAccent,
                                    unselectedLabelColor: Colors.grey,
                                    indicatorColor: Colors.greenAccent,
                                    tabs: [
                                      Tab(
                                          child: Center(
                                              child: Text('Overview',
                                                  style:
                                                  TextStyle(fontSize: 12)))),
                                      Tab(
                                          child: Center(
                                              child: Text('Considerations',
                                                  style:
                                                  TextStyle(fontSize: 10)))),
                                      Tab(
                                          child: Center(
                                              child: Text('Alternatives',
                                                  style:
                                                  TextStyle(fontSize: 12)))),
                                    ],
                                  ),
                                  SizedBox(height: 16),

                                  // TabBarView to display content based on the selected tab
                                  SizedBox(
                                    height:
                                    MediaQuery.of(context).size.height * .25,
                                    child: TabBarView(
                                      children: [
                                        Center(
                                            child: OverviewSection(
                                                text: sections[0])),
                                        Center(
                                            child: ConsiderationsSection(
                                                text: sections[2])),
                                        Center(
                                            child: AlternativesSection(
                                                text: sections[4])),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border:
                            Border.all(color: Colors.greenAccent, width: 2.0),
                          ),
                        ),

                        SizedBox(height: 20,),

                        OutlinedButton(
                          onPressed: () async {

                            String uid = FirebaseAuth.instance.currentUser!.uid;

                            String fileName = path.basename(imagePath);

                            Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

                            await storageRef.putFile(File(imagePath));

                            String downloadURL = await storageRef.getDownloadURL();

                            await DatabaseService(uid: uid).updateUserImages(downloadURL, apiResponse.foodNames, apiResponse.nutriscore, [apiResponse.totalCalories, apiResponse.totalSugar, apiResponse.totalFats, apiResponse.totalSodium, apiResponse.totalFibers, apiResponse.totalProtein], feedbackStore);

                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => Home()),
                            );
                          },
                          child: const Text('Save'),
                          style: ButtonStyle(
                            foregroundColor:
                            WidgetStateProperty.all<Color>(Colors.green),
                            overlayColor:
                            WidgetStateProperty.all<Color>(Colors.amber),
                          ),
                        ),

                        SizedBox(height: 10),
                      ],
                    ) : const CircularProgressIndicator();
                  }
                ),

                // Text("Foods: ${apiResponse.foodNames}\n"
                //     "Total Calories: ${apiResponse.totalCalories}\n"
                //     "Total Fat: ${apiResponse.totalFats}\n"
                //     "Total Cholesterol: ${apiResponse.totalCholesterol}\n"
                //     "Total Sodium: ${apiResponse.totalSodium}\n"
                //     "Total Fibers: ${apiResponse.totalFibers}\n"
                //     "Total Sugars: ${apiResponse.totalSugar}\n"
                //     "Total Protein: ${apiResponse.totalProtein}\n"
                //     "Nutriscore: ${apiResponse.nutriscore}\n")
              ],
            ),
    ));
  }
}
