// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// import 'dart:async';
// import 'dart:convert';
//
// var productID = '';
// var usdaApiKey = 'h3r9HE67APvagn1FErc7B1fJFpSWxgpte6ZGrSgQ';
// var isUSDA = true;
//
// var imageApiKey = 'AIzaSyBa0dktfgY0-9QhwXv3llTz59ZDR09ssv0';
// var cx = '033f69657aaa34f71';
//
//
// class ProductUSDA {
//   final String description;
//   final String brandName;
//   final String ingredients;
//   final List<String> foodNutrients;
//
//   const ProductUSDA({
//     required this.description,
//     required this.brandName,
//     required this.ingredients,
//     required this.foodNutrients,
//   });
//   factory ProductUSDA.fromJson(Map<String, dynamic> json) {
//     // Extract the list of foods from the response
//     List<dynamic> foods;
//     if(isUSDA){
//       foods = json['foods'];
//     }else{
//       foods = List.empty();
//     }
//
//     if (json.isNotEmpty) {
//       // Get the first food item (assuming we're interested in the first result)
//       var food;
//
//       if(isUSDA) {
//         food = foods[0];
//       } else {
//         food = json['product'];
//       }
//
//       // Extract relevant fields
//       String description;
//       String brandName;
//       String ingredients;
//       List<String> foodNutrients;
//
//       if(isUSDA){
//         description = food["description"] ?? "No description";
//         brandName = food['brandName'] ?? 'No brand name';
//         ingredients = food['ingredients'] ?? 'No ingredients';
//         foodNutrients = food['foodNutrients']
//             ?.map((nutrient) => nutrient['nutrientName'])
//             ?.toList()
//             ?.cast<String>() ?? [];
//       }else{
//         description = food['product_name'] ?? 'No product name';
//         brandName = food['brands'] ?? '';
//         ingredients = food['ingredients_text'] ?? 'No ingredients';
//
//         // Extract nutrient information
//         var nutriments = food['nutriments'] ?? {};
//         foodNutrients = [
//           'Energy: ${nutriments['energy-kcal_100g'] ?? 'N/A'} kcal per 100g',
//           'Sugars: ${nutriments['sugars_100g'] ?? 'N/A'} g per 100g',
//           'Fat: ${nutriments['fat_100g'] ?? 'N/A'} g per 100g',
//           'Salt: ${nutriments['salt_100g'] ?? 'N/A'} g per 100g',
//           'Proteins: ${nutriments['proteins_100g'] ?? 'N/A'} g per 100g',
//         ];
//       }
//
//
//       // Create and return the ProductUSDA instance
//       return ProductUSDA(
//         description: description,
//         brandName: brandName,
//         ingredients: ingredients,
//         foodNutrients: foodNutrients,
//       );
//     } else {
//       throw const FormatException('Failed to load product. No foods found.');
//     }
//   }
// }
//
// class ProductImage {
//   final String imageURL;
//
//   const ProductImage({
//     required this.imageURL
//   });
//
//   factory ProductImage.fromJson(Map<String, dynamic> json) {
//     List<dynamic> items;
//
//     items = json['items'];
//
//     if (json.isNotEmpty) {
//       // Extract relevant fields
//       var item = items[0];
//
//       String imageURL;
//
//       imageURL = item["link"] ?? "No image";
//
//       // Create and return the ProductUSDA instance
//       return ProductImage(
//           imageURL: imageURL
//       );
//     } else {
//       throw const FormatException('Failed to load image. No image found.');
//     }
//   }
// }
//
//
// Future<ProductUSDA> fetchProductUSDA() async {
//   final response = await http.get(
//     Uri.parse('https://api.nal.usda.gov/fdc/v1/foods/search?query=$productID&api_key=$usdaApiKey'),
//   );
//
//   if (response.statusCode == 200) {
//     // If the server did return a 200 OK response,
//     // then parse the JSON.
//     isUSDA = true;
//     Map<String, dynamic> test = jsonDecode(response.body) as Map<String, dynamic>;
//     List<dynamic> temp = test['foods'];
//     if(temp.isEmpty){
//       return fetchProductOFF();
//     }
//     return ProductUSDA.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
//   } else {
//
//     return fetchProductOFF();
//   }
// }
//
// Future<ProductUSDA> fetchProductOFF() async {
//   final response = await http.get(
//     Uri.parse('https://world.openfoodfacts.net/api/v2/product/$productID'),
//   );
//   if (response.statusCode == 200) {
//     // If the server did return a 200 OK response,
//     // then parse the JSON.
//     isUSDA = false;
//     return ProductUSDA.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
//
//   } else {
//     // If the server did not return a 200 OK response,
//     // then throw an exception.
//
//     throw Exception('Failed to load product');
//   }
// }
//
// Future<ProductImage> fetchProductImage() async {
//   final response = await http.get(
//     Uri.parse('https://www.googleapis.com/customsearch/v1?key=$imageApiKey&cx=$cx&q=image%20of%20product%20$productID&searchType=image'),
//   );
//
//   if (response.statusCode == 200) {
//     // If the server did return a 200 OK response,
//     // then parse the JSON.
//     return ProductImage.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
//
//   } else {
//
//     throw Exception('Failed to load product image');
//
//   }
// }
//
// // class MyFoodPage extends StatefulWidget {
// //   const MyFoodPage({super.key});
// //
// //   @override
// //   State<MyFoodPage> createState() => _MyFoodState();
// // }
// //
// // class _MyFoodState extends State<MyFoodPage> {
// //   late Future<ProductUSDA> futureProduct;
// //   late Future<ProductImage> futureImage;
// //   late String apiResponse;
// //
// //   String result = '';
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     futureProduct = fetchProductUSDA();
// //
// //     futureImage = fetchProductImage();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Fetch Data Example',
// //       theme: ThemeData(
// //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
// //       ),
// //       home: Scaffold(
// //         appBar: AppBar(
// //           title: const Text('Fetch Data Example'),
// //         ),
// //         body: SingleChildScrollView(
// //             child:Column(
// //               mainAxisSize: MainAxisSize.min ,
// //               children: [
// //                 FutureBuilder<ProductImage>(
// //                   future: futureImage,
// //                   builder: (context, snapshot) {
// //                     if (snapshot.hasData) {
// //                       return Image.network(snapshot.data!.imageURL);
// //                     } else if (snapshot.hasError) {
// //                       return Text('${snapshot.error}');
// //                     }
// //                     // By default, show a loading spinner.
// //                     return const CircularProgressIndicator();
// //                   },
// //                 ),
// //                 FutureBuilder<ProductUSDA>(
// //                   future: futureProduct,
// //                   builder: (context, snapshot) {
// //                     if (snapshot.hasData) {
// //                       return Text("Product: ${snapshot.data!.brandName} ${snapshot.data!.description}\n\n\n\nIngredients: ${snapshot.data!.ingredients}\n\nNutrients: ${snapshot.data!.foodNutrients}");
// //                     } else if (snapshot.hasError) {
// //                       return Text('${snapshot.error}');
// //                     }
// //
// //                     // By default, show a loading spinner.
// //                     return const CircularProgressIndicator();
// //                   },
// //                 ),
// //
// //                 ElevatedButton(
// //                   onPressed: (){
// //                     Navigator.pop(context);
// //                   }, child: const Text('Done'),
// //                 )
// //               ],
// //             )
// //
// //         ),
// //       ),
// //     );
// //   }
// // }
