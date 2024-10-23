import 'package:Nutritrack/screens/home/food_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/database.dart';


class FoodHistory extends StatefulWidget {
  const FoodHistory({super.key});

  @override
  State<FoodHistory> createState() => _FoodHistory();
}

class _FoodHistory extends State<FoodHistory> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  List<dynamic> foodHistory = [];

  @override
  void initState() {
    super.initState();
    createList();
  }

  Future<void> createList() async {
    var data = DatabaseService(uid: uid).getFoodData();

    await for (dynamic field in data) {
      if (field.foodHistory != null && field.foodHistory is List) {
        setState(() {
          foodHistory = field.foodHistory; // Store the food history
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffebebeb),
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0),
          decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(5)
          ),
          child: const Text("Nutritrack"),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xff212435),
          iconSize: 24,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.green,
        elevation: 10,
      ),
      body: foodHistory.isNotEmpty
          ? ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        itemCount: foodHistory.length,
        itemBuilder: (context, index) {
          String nutriscore = foodHistory[index]["nutriScore"] ?? 'N/A';
          String imageUrl = foodHistory[index]["image-request"] ?? '';
          String foodNames = foodHistory[index]["name"] ?? 'Unknown';
          List<dynamic> nutrients = foodHistory[index]["nutrients"] ?? List.empty();
          String feedback = foodHistory[index]['feedback'] ?? 'No description';

          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 3, 0, 3),
            child: Card(
              margin: const EdgeInsets.all(0),
              color: const Color(0xffffffff),
              shadowColor: const Color(0xff000000),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CapturedImage(
                        imageUrl: imageUrl,
                        nutriScore: nutriscore,
                        foodNames: foodNames,
                        nutrients: nutrients,
                        feedback: feedback,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12.0),
                        bottomLeft: Radius.circular(12.0),
                      ),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.fitHeight,
                        height: MediaQuery.of(context).size.height * 0.20,
                        width: MediaQuery.of(context).size.width * 0.40,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                      ),
                    ),

                    const VerticalDivider(width: 10, color: Colors.greenAccent,thickness: 2,),

                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              foodNames,
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Colors.black45,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const SizedBox(height: 20),
                            Center(
                              child: Text(
                                nutriscore,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 30,
                                  color: nutriscoreColor(nutriscore),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  // Helper function to determine the NutriScore color
  Color nutriscoreColor(String nutriscore) {
    switch (nutriscore) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.lightGreen;
      case 'C':
        return Colors.yellow;
      case 'D':
        return Colors.orange;
      case 'E':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
