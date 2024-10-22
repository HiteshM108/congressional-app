import 'dart:ffi';

import 'package:Nutritrack/screens/home/food_not_found.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Nutritrack/models/user.dart';
import 'package:Nutritrack/screens/home/home.dart';
import 'package:Nutritrack/services/auth.dart';
import 'package:Nutritrack/services/database.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

var productID = '';
var usdaApiKey = 'h3r9HE67APvagn1FErc7B1fJFpSWxgpte6ZGrSgQ';
var isUSDA = true;

var imageApiKey = [
  'AIzaSyBa0dktfgY0-9QhwXv3llTz59ZDR09ssv0',
  'AIzaSyD68z07h1XA0Gj15f_xeo3VNrgYeNHVzWE'
];
var cx = '033f69657aaa34f71';
var productDescription = '';

const geminiApiKey =
    String.fromEnvironment('AIzaSyDCwXGUxGbJhfpz6GfENeP4oUpKp6yaLXo');

final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    systemInstruction: Content.text(
        "For context, you are integrated into an app designed to help people determine what they should be eating. You will be given background information about the person. The person will scan a given product and the product will be then told to you and you are to give advice about the product based on the person's background information. The information you will provide is not to be like a conversation but just information. Structure your response to have a first a short paragraph on the overview of the product, then a paragraph about considerations, and then lastly a paragraph on alternatives"),
    apiKey: 'AIzaSyDCwXGUxGbJhfpz6GfENeP4oUpKp6yaLXo');

final model2 = GenerativeModel(model: 'gemini-1.5-flash', apiKey: 'AIzaSyDCwXGUxGbJhfpz6GfENeP4oUpKp6yaLXo');


class ProductUSDA {
  final String description;
  final String brandName;
  final String ingredients;
  final List<String> foodNutrients;
  final double energy;
  final double sugars;
  final double saturatedFats;
  final double sodium;
  final double fiber;
  final double protein;

  const ProductUSDA(
      {required this.description,
      required this.brandName,
      required this.ingredients,
      required this.foodNutrients,
      required this.energy,
      required this.sugars,
      required this.saturatedFats,
      required this.sodium,
      required this.fiber,
      required this.protein});

  factory ProductUSDA.fromJson(Map<String, dynamic> json) {
    // Extract the list of foods from the response
    List<dynamic> foods;
    if (isUSDA) {
      foods = json['foods'];
    } else {
      foods = List.empty();
    }

    if (json.isNotEmpty) {
      // Get the first food item (assuming we're interested in the first result)
      var food;

      if (isUSDA) {
        food = foods[0];
      } else {
        food = json['product'];
      }

      // Extract relevant fields
      String description;
      String brandName;
      String ingredients;
      List<String> foodNutrients;
      double energy = 0.0;
      double sugars = 0.0;
      double saturatedFats = 0.0;
      double sodium = 0.0;
      double fiber = 0.0;
      double protein = 0.0;

      if (isUSDA) {
        description = food["description"] ?? "No description";
        brandName = food['brandName'] ?? 'No brand name';
        ingredients = food['ingredients'] ?? 'No ingredients';
        foodNutrients = food['foodNutrients']?.map<String>((nutrient) {
              return "${nutrient['nutrientName']}: ${nutrient['value']} ${nutrient['unitName']}";
            }).toList() ??
            [];
        energy =
            double.parse(getNutrientValue(foodNutrients, "Energy") ?? "0.0");
        sugars = double.parse(
            getNutrientValue(foodNutrients, "Total Sugars") ?? "0.0");
        saturatedFats = double.parse(
            getNutrientValue(foodNutrients, "Fatty acids, total saturated") ??
                "0.0");
        sodium = double.parse(
            getNutrientValue(foodNutrients, "Sodium, Na") ?? "0.0");
        fiber = double.parse(
            getNutrientValue(foodNutrients, "Fiber, total dietary") ?? "0.0");
        protein =
            double.parse(getNutrientValue(foodNutrients, "Protein") ?? "0.0");
      } else {
        description = food['product_name'] ?? 'No product name';
        brandName = food['brands'] ?? '';
        ingredients = food['ingredients_text'] ?? 'No ingredients';

        // Extract nutrient information
        var nutriments = food['nutriments'] ?? {};
        foodNutrients = [
          'Energy: ${nutriments['energy-kcal_100g'] ?? 'N/A'} kcal per 100g',
          'Sugars: ${nutriments['sugars_100g'] ?? 'N/A'} g per 100g',
          'Fat: ${nutriments['fat_100g'] ?? 'N/A'} g per 100g',
          'Salt: ${nutriments['salt_100g'] ?? 'N/A'} g per 100g',
          'Proteins: ${nutriments['proteins_100g'] ?? 'N/A'} g per 100g',
        ];
        energy = (nutriments['energy_100g'] ?? 0.0).toDouble();
        sugars = (nutriments['sugars_100g'] ?? 0.0).toDouble();
        saturatedFats = (nutriments['saturated-fat_100g'] ?? 0.0).toDouble();
        sodium = ((nutriments['sodium_100g'] ?? 0.0) * 100).toDouble();
        fiber = (nutriments['fiber_100g'] ?? 0.0).toDouble();
        protein = (nutriments['proteins_100g'] ?? 0.0).toDouble();
      }
      debugPrint("3");

      productDescription = description;

      debugPrint("4");

      // Create and return the ProductUSDA instance
      return ProductUSDA(
          description: description,
          brandName: brandName,
          ingredients: ingredients,
          foodNutrients: foodNutrients,
          energy: energy,
          sugars: sugars,
          saturatedFats: saturatedFats,
          sodium: sodium,
          fiber: fiber,
          protein: protein);
    } else {
      throw const FormatException('Failed to load product. No foods found.');
    }
  }
}

class ProductImage {
  final String imageURL;

  const ProductImage({required this.imageURL});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    List<dynamic> items;

    items = json['items'];

    if (json.isNotEmpty) {
      // Extract relevant fields
      var item = items[0];

      String imageURL;

      imageURL = item["link"] ?? "No image";

      // Create and return the ProductUSDA instance
      return ProductImage(imageURL: imageURL);
    } else {
      throw const FormatException('Failed to load image. No image found.');
    }
  }
}

Future<ProductUSDA> fetchProductUSDA() async {
  final response = await http.get(
    Uri.parse(
        'https://api.nal.usda.gov/fdc/v1/foods/search?query=$productID&api_key=$usdaApiKey'),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    isUSDA = true;
    Map<String, dynamic> test =
        jsonDecode(response.body) as Map<String, dynamic>;
    List<dynamic> temp = test['foods'];
    if (temp.isEmpty) {
      return fetchProductOFF();
    }
    return ProductUSDA.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    return fetchProductOFF();
  }
}

Future<ProductUSDA> fetchProductOFF() async {
  final response = await http.get(
    Uri.parse('https://world.openfoodfacts.net/api/v2/product/$productID'),
  );
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    isUSDA = false;
    return ProductUSDA.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.

    throw ProductUSDA.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }
}

Future<ProductImage> fetchProductImage() async {
  // final response = await http.get(
  //   Uri.parse('https://www.googleapis.com/customsearch/v1?key=$imageApiKey&cx=$cx&q=image%20of%20product%20$productID&searchType=image'),
  // );

  var temp = productDescription;
  temp = productDescription.replaceAll('&', 'and');

  var response = await http.get(
    Uri.parse(
        'https://www.googleapis.com/customsearch/v1?key=${imageApiKey[0]}&cx=$cx&q=$temp&searchType=image'),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return ProductImage.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    response = await http.get(
      Uri.parse(
          'https://www.googleapis.com/customsearch/v1?key=${imageApiKey[1]}&cx=$cx&q=$temp&searchType=image'),
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return ProductImage.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load product image');
    }
  }
}

Future<String> getScanFeedback(String itemName, String description) async {
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
    print(description);

    geminiResponse = (await model.generateContent([
      Content.text(
          "Provide personalized feedback on this food item based on this person's description and goals. The person is a ${field.gender} aged ${field.age} years old whose exercise level is ${field.activityLevel}. The person is ${field.height} inches tall and weighs ${field.weight} pounds. The person is looking to eat a ${itemName} ${description}")
    ]))
        .text!;

    break;
  }

  return geminiResponse;
}

String? getNutrientValue(List<String> foodNutrients, String nutrientName) {
  // Find the nutrient entry that contains the specified nutrientName
  final nutrientEntry = foodNutrients.firstWhere(
    (nutrient) => nutrient.contains(nutrientName),
    orElse: () => "",
  );

  // If the nutrient was found, split and return the value
  if (nutrientEntry.isNotEmpty) {
    // Split by space and take the second element, which is the value
    String nutrientValue = nutrientEntry.split(": ")[1].split(" ")[0];
    final nutrientUnit = nutrientEntry.split(": ")[1].split(" ")[1];
    if (nutrientName == "Energy" && nutrientUnit == "KCAL") {
      nutrientValue = (double.parse(nutrientValue) * 4.18).toString();
    }
    return nutrientValue;
  }

  return null;
}

String calculateNutriScore(double energy, double sugars, double saturatedFats,
    double sodium, double fiber, double protein) {
  int energyPoints = (energy / 335).clamp(0, 10).toInt();
  int sugarsPoints = (sugars / 4.5).clamp(0, 10).toInt();
  int satFatsPoints = saturatedFats.clamp(0, 10).toInt();
  int sodiumPoints = (sodium / 90).clamp(0, 10).toInt();

  int negativePoints =
      energyPoints + sugarsPoints + satFatsPoints + sodiumPoints;

  int fiberPoints = (fiber / 1.2).clamp(0, 5).toInt();
  int proteinPoints = (protein / 1.6).clamp(0, 5).toInt();

  int positivePoints = fiberPoints + proteinPoints;

  int nutriScore = negativePoints - positivePoints;

  if (nutriScore <= -1) return 'A';
  if (nutriScore <= 2) return 'B';
  if (nutriScore <= 10) return 'C';
  if (nutriScore <= 18) return 'D';
  return 'E';
}

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<Scan> createState() => _MyFoodState();
}

class _MyFoodState extends State<Scan> {
  late Future<ProductUSDA> futureProduct;
  late Future<ProductImage> futureImage;
  late Future<String> futureFeedback;

  // String geminiResponse = "";
  final Completer<ProductUSDA> productCompleter = Completer();
  final Completer<ProductImage> imageCompleter = Completer();
  final Completer<String> feedbackCompleter = Completer();
  late String apiResponse;
  String result = '';

  // Scan Properties
  // "\nProduct: ${snapshot.data!.brandName} ${snapshot.data!.description}\n\n\n\nIngredients: ${snapshot.data!.ingredients}\n\nNutrients: ${snapshot.data!.foodNutrients}\n\nNutriscore: $nutriScore\n\nRecommendations: $geminiResponse"),
  late String imageRequest;
  late String itemName;
  late String description;
  late String nutriScore;
  late String feedback;
  late String geminiProductName;
  late List<String> ingredients;
  late List<double> nutrients;

  @override
  void initState() {
    super.initState();
    futureProduct = productCompleter.future;
    futureImage = imageCompleter.future;
    futureFeedback = feedbackCompleter.future;
    fetchStuff();
  }

  void fetchStuff() async {
    try {
      var product = await fetchProductUSDA();

      productDescription = product.description;
      var brandName = product.brandName;

      geminiProductName = (await model2.generateContent([Content.text("Taking in brand name and product name output full name of product as displayed on a store website. Brand name is $brandName and Product name is $productDescription.  Be careful that sometimes there could me missing a brand name or a product name but still try to get an educated guess on what the product actually is. Only output full product name and nothing else. Make it properly capitalized")])).text!;

      var image = await fetchProductImage();

      print("COMPLETERS");

      productCompleter.complete(product);
      imageCompleter.complete(image);

      print("NAMES");
      print(product.brandName);
      print(product.description);
      var geminiResponse =
          await getScanFeedback(product.brandName, product.description);
      print(geminiResponse);

      feedbackCompleter.complete(geminiResponse);

      print("FINISHED RUN");
    } catch (e) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodNotFound(),
          ));

      debugPrint("Error fetching product: $e");
      productCompleter.completeError(e);
      imageCompleter.completeError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: SingleChildScrollView(
          child: Flex(
        mainAxisSize: MainAxisSize.min,
        direction: Axis.vertical,
        children: [
          FutureBuilder<ProductImage>(
            future: futureImage,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasData) {
                imageRequest = snapshot.data!.imageURL;

                return Stack(
                  children: [
                    Center(
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * .5,
                        height: MediaQuery.sizeOf(context).width * .5,
                        decoration: BoxDecoration(
                            border: Border.fromBorderSide(
                                BorderSide(color: Colors.amber, width: 2)),
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.grey[200]),
                        child: Image.network(snapshot.data!.imageURL),
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
                );
              } else if (snapshot.hasError) {
                return Container();
              }
              // By default, show a loading spinner.
              // return Column(
              //     children: [
              //       CircularProgressIndicator(),
              //     ],
              //   mainAxisAlignment: MainAxisAlignment.center,
              // );
              return Container();
            },
          ),
          FutureBuilder<ProductUSDA>(
            future: futureProduct,
            builder: (context, snapshot) {
              print("BRAND NAME");
              print(snapshot.data?.brandName);
              if (snapshot.hasData) {
                ProductUSDA product = snapshot.data!;
                nutriScore = calculateNutriScore(
                  product.energy,
                  product.sugars,
                  product.saturatedFats,
                  product.sodium,
                  product.fiber,
                  product.protein,
                );

                itemName = snapshot.data!.brandName;
                description = snapshot.data!.description;

                ingredients = snapshot.data!.ingredients.split(", ");

                for (int i = 0; i < ingredients.length; i++) {
                  ingredients[i] = toBeginningOfSentenceCase(ingredients[i]
                      .replaceAll('(', '')
                      .replaceAll(')', '')
                      .replaceAll('[', '')
                      .replaceAll(']', '')
                      .replaceAll('.', '')
                      .toLowerCase());
                }

                ingredients = ingredients.toSet().toList();

                nutrients = [
                  product.energy,
                  product.sugars,
                  product.saturatedFats,
                  product.sodium,
                  product.fiber,
                  product.protein
                ];

                return Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),

                    Divider(
                      color: Colors.greenAccent,
                      height: 1.0,
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            toBeginningOfSentenceCase(
                                geminiProductName.toLowerCase()),
                            style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center,),
                      ],
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.greenAccent),
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      width: MediaQuery.sizeOf(context).width * .5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Nutriscore",
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            nutriScore,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    Divider(
                      color: Colors.greenAccent,
                      height: 1.0,
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    Container(
                      child: Text(
                        "Nutrition Advisor",
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border:
                            Border.all(color: Colors.greenAccent, width: 1.0),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                    ),

                    SizedBox(
                      height: 10,
                    ),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.grey, width: 2.0),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.greenAccent),
                          child: Icon(MdiIcons.fromString("spoon-sugar")),
                        ),
                        title: Text(
                          "Energy",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        trailing: Container(
                          child: Text(
                            "${nutrients[0].toStringAsFixed(2)} kJ",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.grey, width: 2.0),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.greenAccent),
                          child: Icon(MdiIcons.fromString("spoon-sugar")),
                        ),
                        title: Text(
                          "Sugars",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        trailing: Container(
                          child: Text(
                            "${nutrients[1]} g",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.grey, width: 2.0),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.greenAccent),
                          child: Icon(MdiIcons.fromString("water-outline")),
                        ),
                        title: Text(
                          "Saturated Fats",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        trailing: Container(
                          child: Text(
                            "${nutrients[2]} g",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.grey, width: 2.0),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.greenAccent),
                          child: Icon(MdiIcons.fromString("shaker-outline")),
                        ),
                        title: Text(
                          "Sodium",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        trailing: Container(
                          child: Text(
                            "${nutrients[3]} mg",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.grey, width: 2.0),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.greenAccent),
                          child: Icon(MdiIcons.fromString("barley")),
                        ),
                        title: Text(
                          "Fiber",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        trailing: Container(
                          child: Text(
                            "${nutrients[4]} g",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.grey, width: 2.0),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.greenAccent),
                          child: Icon(
                              MdiIcons.fromString("food-drumstick-outline")),
                        ),
                        title: Text(
                          "Protein",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        trailing: Container(
                          child: Text(
                            "${nutrients[5]} g",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    Divider(
                      color: Colors.greenAccent,
                      height: 1.0,
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    Container(
                      child: Text(
                        "Ingredients List",
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border:
                            Border.all(color: Colors.greenAccent, width: 1.0),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    ),

                    SizedBox(
                      height: 5,
                    ),

                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * .5,
                      child: Scrollbar(
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: ingredients.length,
                          itemBuilder: (BuildContext cntxt, int index) {
                            return Flex(direction: Axis.vertical, children: [
                              ListTile(
                                title: Text(
                                  ingredients[index],
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                trailing: Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(75),
                                      color: Colors.greenAccent),
                                ),
                              ),
                              Divider(
                                color: Colors.grey[300],
                                height: 1,
                              )
                            ]);
                          },
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    Divider(
                      color: Colors.greenAccent,
                      height: 1.0,
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    // Text(
                    //     "\nProduct: ${snapshot.data!.brandName} ${snapshot.data!.description}\n\n\n\nIngredients: ${snapshot.data!.ingredients}\n\nNutrients: ${snapshot.data!.foodNutrients}\n\nNutriscore: $nutriScore\n\nRecommendations: $geminiResponse"),
                  ],
                );
              } else if (snapshot.hasError) {
                return Container();
              }

              // By default, show a loading spinner.
              return Container();
            },
          ),
          FutureBuilder(
              future: futureFeedback,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  feedback = snapshot.data!;

                  print(feedback);
                  var sections = feedback.split("\n");
                  print("SECTIONS");
                  print(sections.toString());

                  return Column(
                    children: [
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
                                                    TextStyle(fontSize: 12)))),
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
                                      MediaQuery.of(context).size.height * .2,
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

                      // Expanded(
                      //   child: DefaultTabController(
                      //     length: 3,
                      //     child: Scaffold(
                      //       appBar: TabBar(
                      //         title: Text('Personalized Feedback'),
                      //         bottom: const TabBar(
                      //           tabs: [
                      //             Tab(text: 'Overview'),
                      //             Tab(text: 'Considerations'),
                      //             Tab(text: 'Alternatives'),
                      //           ],
                      //         ),
                      //       ),
                      //       body: TabBarView(
                      //         children: [
                      //           OverviewSection(text: sections[0]),
                      //           ConsiderationsSection(text: sections[1]),
                      //           AlternativesSection(text: sections[2]),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      SizedBox(
                        height: 20,
                      ),

                      // Text(feedback),
                      OutlinedButton(
                        onPressed: () async {
                          String uid = FirebaseAuth.instance.currentUser!.uid;

                          await DatabaseService(uid: uid).updateUserScans(
                              imageRequest,
                              geminiProductName,
                              description,
                              feedback,
                              nutriScore,
                              ingredients,
                              nutrients);

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
                    ],
                  );
                }

                return Container();
              }),
        ],
      )),
    );
  }
}

class OverviewSection extends StatelessWidget {
  final text;

  const OverviewSection({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ));
  }
}

class ConsiderationsSection extends StatelessWidget {
  final text;

  const ConsiderationsSection({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ));
  }
}

class AlternativesSection extends StatelessWidget {
  final text;

  const AlternativesSection({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ));
  }
}
