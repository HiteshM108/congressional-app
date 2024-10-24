import 'package:Nutritrack/screens/home/food_history.dart';
import 'package:Nutritrack/screens/home/food_image.dart';
import 'package:Nutritrack/screens/home/scanned_history.dart';
import 'package:Nutritrack/screens/home/scanned_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import '../../services/database.dart';
import 'home.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {

  String uid = FirebaseAuth.instance.currentUser!.uid;


  Widget? scanItem;
  Widget? foodImage;

  @override
  void initState() {
    super.initState();
    createList();
  }

  Future<void> createUserData() async{

    var userData = DatabaseService(uid: uid).getUserData();

    // await for (dynamic field in userData) {
    //   debugPrint('bruh');
    //   setState(() {
    //     debugPrint('test');
    //     name = field.name;
    //   });
    //   debugPrint('ads');
    // }
  }

  Future<void> createFoodData() async{
    var foodData = DatabaseService(uid: uid).getFoodData();

    await for (dynamic foodField in foodData) {
      int j = foodField.foodHistory.length - 1;
      j = 0;
      String foodNutriscore = foodField.foodHistory[j]["nutriScore"];
      setState(() {
        foodImage = Card(
            margin: EdgeInsets.all(0),
            color: Colors.white,
            shadowColor: Color(0xff000000),
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(color: Colors.grey, width: 2.0, style: BorderStyle.solid),
            ),
            child: InkWell(
              onTap: (){
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CapturedImage(
                      imageUrl: foodField.foodHistory[j]["image-request"],
                      nutriScore: foodField.foodHistory[j]["nutriScore"],
                      foodNames: foodField.foodHistory[j]["name"],
                      nutrients: foodField.foodHistory[j]["nutrients"],
                      feedback: foodField.foodHistory[j]['feedback'],
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [

                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.0),
                        bottomLeft: Radius.circular(12.0)),
                    child:
                    Image(
                      image: NetworkImage(
                          foodField.foodHistory[j]["image-request"]),
                      fit: BoxFit.fitHeight,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.20,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.40,
                    ),
                  ),

                  VerticalDivider(width: 10, color: Colors.grey,thickness: 2,),

                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                      child:
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            foodField.foodHistory[j]["name"],
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                            child: Text(
                              "",
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 12,
                                color: Color(0xff7a7a7a),
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: Text(
                              foodNutriscore,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontStyle: FontStyle.normal,
                                fontSize: 30,
                                color: (foodNutriscore == 'A' ? Colors.green :
                                (foodNutriscore == 'B' ? Colors.lightGreen :
                                (foodNutriscore == 'C' ? Colors.yellow :
                                (foodNutriscore == 'D' ? Colors.orange : Colors
                                    .red)))),
                              ),
                            ),
                          ),
                        ],),),),
                ],),
            )
        );
      });
    }
  }

  Future<void> createList() async {
    var scanData = DatabaseService(uid: uid).getScanData();

    createUserData();

    createFoodData();

      await for (dynamic scanField in scanData) {
          int i = scanField.scanHistory.length - 1;
          i = 0;

          String scanNutriscore = scanField.scanHistory[i]["nutriScore"];


          setState(() {
            scanItem = Card(
              margin: EdgeInsets.all(0),
              color: Color(0xffffffff),
              shadowColor: Color(0xff000000),
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(color: Colors.grey, width: 2.0, style: BorderStyle.solid),
              ),
              child: InkWell(
                onTap: (){
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ScannedItem(
                        imageUrl: scanField.scanHistory[i]["image-request"],
                        nutriScore: scanField.scanHistory[i]["nutriScore"],
                        brandName: scanField.scanHistory[i]["name"],
                        productDescription: scanField.scanHistory[i]["description"],
                        nutrients: scanField.scanHistory[i]["nutrients"],
                        ingredients: scanField.scanHistory[i]["ingredients"],
                        feedback: scanField.scanHistory[i]["feedback"],
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          bottomLeft: Radius.circular(12.0)),
                      child:
                      Image(
                        image: NetworkImage(
                            scanField.scanHistory[i]["image-request"]),
                        fit: BoxFit.cover,
                        height: MediaQuery
                            .of(context)
                            .size
                            .height * 0.20,
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.40,
                      ),
                    ),

                    // Divider(height: 5, color: Colors.grey,),
                    // Text("test"),
                    VerticalDivider(width: 10, color: Colors.grey,thickness: 2,),

                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                        child:
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              scanField.scanHistory[i]["name"],
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                              child: Text(
                                "",
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 12,
                                  color: Color(0xff7a7a7a),
                                ),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  scanNutriscore,
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 30,
                                    color: (scanNutriscore == 'A' ? Colors.green :
                                    (scanNutriscore == 'B' ? Colors.lightGreen :
                                    (scanNutriscore == 'C' ? Colors.yellow :
                                    (scanNutriscore == 'D' ? Colors.orange : Colors
                                        .red)))),
                                  ),
                                ),
                              ),
                            ),
                          ],),),),
                  ],),
              ),
            );
          });
        }
      }

  void showScanBackDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("No Scans Yet"),
          content: const Text(
              "Please scan your first item."),
          actions: <Widget>[
            TextButton(
              child: const Text("Back"),
              onPressed: () {
                Navigator.pop(context); // Go back to the camera screen
              },
            ),
          ],
        );
      },
    );
  }

  void showCamBackDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("No Captures Yet"),
          content: const Text(
              "Please take a picture of your first food!"),
          actions: <Widget>[
            TextButton(
              child: const Text("Back"),
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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body:Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          // margin:EdgeInsets.all(0),
          // padding:EdgeInsets.all(0),
          // width:MediaQuery.of(context).size.width,
          // height:MediaQuery.of(context).size.height,
          child:
          SingleChildScrollView(
            child:
            Column(
              mainAxisAlignment:MainAxisAlignment.start,
              crossAxisAlignment:CrossAxisAlignment.center,
              mainAxisSize:MainAxisSize.max,
              children: [
                // Padding(
                //   padding:EdgeInsets.fromLTRB(0, 10, 0, 0),
                //   child:Align(
                //     alignment:Alignment(-0.95, 0.0),
                //     child:Text(
                //       "Hello $name!",
                //       textAlign: TextAlign.start,
                //       overflow:TextOverflow.clip,
                //       style:TextStyle(
                //         fontWeight:FontWeight.w800,
                //         fontStyle:FontStyle.normal,
                //         fontSize:20,
                //         color:Color(0xff000000),
                //       ),
                //     ),
                //   ),
                // ),
                Padding(
                  padding:EdgeInsets.fromLTRB(0, 15, 0, 5),
                  child:Row(
                    mainAxisAlignment:MainAxisAlignment.center,
                    crossAxisAlignment:CrossAxisAlignment.center,
                    mainAxisSize:MainAxisSize.max,
                    children:[

                      Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: 50,
                        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey, width: 2.0),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                              alignment:Alignment(-0.8, 0.0),
                              child:Text(
                                "Scan History",
                                textAlign: TextAlign.start,
                                overflow:TextOverflow.clip,
                                style:TextStyle(
                                  fontWeight:FontWeight.w800,
                                  fontStyle:FontStyle.normal,
                                  fontSize:20,
                                  color:Colors.green,
                                ),
                              ),
                            ),
                            Align(
                              alignment:Alignment(0.8, 0.0),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.amber,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                      style:TextStyle(
                                        fontWeight:FontWeight.w400,
                                        fontStyle:FontStyle.normal,
                                        fontSize:16,
                                        color:Colors.white,
                                      ),
                                      text: 'See More',
                                      recognizer: TapGestureRecognizer()..onTap = (){
                                        scanItem != null ? Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ScannedHistory(),
                                            )) : showScanBackDialog();
                                      }
                                  ),
                                  textAlign: TextAlign.start,
                                  overflow:TextOverflow.clip,
                                ),
                              ),
                            ),
                          ]
                        )
                      ),
                    ],),),
                Container(
                    margin:EdgeInsets.all(0),
                    padding:EdgeInsets.zero,
                    width:MediaQuery.of(context).size.width * 0.85,
                    height:MediaQuery.of(context).size.height * 0.2,
                    child: scanItem ?? const Center(child: Text("Please take your first scan!"))
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.1,),

                Padding(
                  padding:EdgeInsets.fromLTRB(0, 15, 0, 5),
                  child:Row(
                    mainAxisAlignment:MainAxisAlignment.center,
                    crossAxisAlignment:CrossAxisAlignment.center,
                    mainAxisSize:MainAxisSize.max,
                    children:[

                      Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          height: 50,
                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey, width: 2.0),
                            color: Colors.white,
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Align(
                                  alignment:Alignment(-0.8, 0.0),
                                  child:Text(
                                    "Camera History",
                                    textAlign: TextAlign.start,
                                    overflow:TextOverflow.clip,
                                    style:TextStyle(
                                      fontWeight:FontWeight.w800,
                                      fontStyle:FontStyle.normal,
                                      fontSize:20,
                                      color:Colors.green,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment:Alignment(0.8, 0.0),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.amber,
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                          style:TextStyle(
                                            fontWeight:FontWeight.w400,
                                            fontStyle:FontStyle.normal,
                                            fontSize:16,
                                            color:Colors.white,
                                          ),
                                          text: 'See More',
                                          recognizer: TapGestureRecognizer()..onTap = (){
                                            foodImage != null ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => FoodHistory(),
                                                )) : showCamBackDialog();
                                          }
                                      ),
                                      textAlign: TextAlign.start,
                                      overflow:TextOverflow.clip,
                                    ),
                                  ),
                                ),
                              ]
                          )
                      ),
                    ],),),
                Container(
                    margin:EdgeInsets.zero,
                    padding:EdgeInsets.zero,
                    width:MediaQuery.of(context).size.width * 0.85,
                    height:MediaQuery.of(context).size.height * 0.2,
                    child:foodImage ?? Center(child: Text("Please take a picture of your first food!"))
                ),

                /*
                Padding(
                  padding:EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child:Align(
                    alignment:Alignment(-0.9, 0.0),
                    child:Text(
                      "Daily Nutritional Goals",
                      textAlign: TextAlign.start,
                      overflow:TextOverflow.clip,
                      style:TextStyle(
                        fontWeight:FontWeight.w700,
                        fontStyle:FontStyle.normal,
                        fontSize:18,
                        color:Color(0xff006d28),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding:EdgeInsets.fromLTRB(5, 30, 5, 0),
                  child:Row(
                    mainAxisAlignment:MainAxisAlignment.center,
                    crossAxisAlignment:CrossAxisAlignment.center,
                    mainAxisSize:MainAxisSize.max,
                    children:[
                      TextButton(onPressed: (){
                        createList();
                      }, child: Text("test")),

                      Text(
                        "    ",
                        textAlign: TextAlign.start,
                        overflow:TextOverflow.clip,
                        style:TextStyle(
                          fontWeight:FontWeight.w400,
                          fontStyle:FontStyle.normal,
                          fontSize:14,
                          color:Color(0xff000000),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: LinearProgressIndicator(
                            backgroundColor: Color(0xff808080),
                            valueColor: new AlwaysStoppedAnimation<Color>(Color(0xff3a57e8)),
                            value: 0.5,
                            minHeight: 5
                        ),
                      ),
                    ],),),
                Row(
                  mainAxisAlignment:MainAxisAlignment.center,
                  crossAxisAlignment:CrossAxisAlignment.center,
                  mainAxisSize:MainAxisSize.max,
                  children:[

                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment:Alignment(-0.8, 0.0),
                        child:Text(
                          "Calories",
                          textAlign: TextAlign.start,
                          overflow:TextOverflow.clip,
                          style:TextStyle(
                            fontWeight:FontWeight.w600,
                            fontStyle:FontStyle.normal,
                            fontSize:14,
                            color:Color(0xff000000),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment:Alignment(-0.8, 0.0),
                        child:Text(
                          "Protein",
                          textAlign: TextAlign.start,
                          overflow:TextOverflow.clip,
                          style:TextStyle(
                            fontWeight:FontWeight.w600,
                            fontStyle:FontStyle.normal,
                            fontSize:14,
                            color:Color(0xff000000),
                          ),
                        ),
                      ),
                    ),
                  ],),
                Padding(
                  padding:EdgeInsets.fromLTRB(5, 30, 5, 0),
                  child:Row(
                    mainAxisAlignment:MainAxisAlignment.center,
                    crossAxisAlignment:CrossAxisAlignment.center,
                    mainAxisSize:MainAxisSize.max,
                    children:[

                      Expanded(
                        flex: 1,
                        child: LinearProgressIndicator(
                            backgroundColor: Color(0xff808080),
                            valueColor: new AlwaysStoppedAnimation<Color>(Color(0xff3a57e8)),
                            value: 0.5,
                            minHeight: 5
                        ),
                      ),
                      Text(
                        "   ",
                        textAlign: TextAlign.start,
                        overflow:TextOverflow.clip,
                        style:TextStyle(
                          fontWeight:FontWeight.w400,
                          fontStyle:FontStyle.normal,
                          fontSize:14,
                          color:Color(0xff000000),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: LinearProgressIndicator(
                            backgroundColor: Color(0xff808080),
                            valueColor: new AlwaysStoppedAnimation<Color>(Color(0xff3a57e8)),
                            value: 0.5,
                            minHeight: 5
                        ),
                      ),
                    ],),),
                Row(
                  mainAxisAlignment:MainAxisAlignment.center,
                  crossAxisAlignment:CrossAxisAlignment.center,
                  mainAxisSize:MainAxisSize.max,
                  children:[

                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment:Alignment(-0.8, 0.0),
                        child:Text(
                          "Fats",
                          textAlign: TextAlign.start,
                          overflow:TextOverflow.clip,
                          style:TextStyle(
                            fontWeight:FontWeight.w600,
                            fontStyle:FontStyle.normal,
                            fontSize:14,
                            color:Color(0xff000000),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment:Alignment(-0.8, 0.0),
                        child:Text(
                          "Fibers",
                          textAlign: TextAlign.start,
                          overflow:TextOverflow.clip,
                          style:TextStyle(
                            fontWeight:FontWeight.w600,
                            fontStyle:FontStyle.normal,
                            fontSize:14,
                            color:Color(0xff000000),
                          ),
                        ),
                      ),
                    ),
                  ],),
                Padding(
                  padding:EdgeInsets.fromLTRB(5, 30, 5, 0),
                  child:Row(
                    mainAxisAlignment:MainAxisAlignment.center,
                    crossAxisAlignment:CrossAxisAlignment.center,
                    mainAxisSize:MainAxisSize.max,
                    children:[

                      Expanded(
                        flex: 1,
                        child: LinearProgressIndicator(
                            backgroundColor: Color(0xff808080),
                            valueColor: new AlwaysStoppedAnimation<Color>(Color(0xff3a57e8)),
                            value: 0.5,
                            minHeight: 5
                        ),
                      ),
                      Text(
                        "   ",
                        textAlign: TextAlign.start,
                        overflow:TextOverflow.clip,
                        style:TextStyle(
                          fontWeight:FontWeight.w400,
                          fontStyle:FontStyle.normal,
                          fontSize:14,
                          color:Color(0xff000000),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: LinearProgressIndicator(
                            backgroundColor: Color(0xff808080),
                            valueColor: new AlwaysStoppedAnimation<Color>(Color(0xff3a57e8)),
                            value: 0.5,
                            minHeight: 5
                        ),
                      ),
                    ],),),
                Row(
                  mainAxisAlignment:MainAxisAlignment.center,
                  crossAxisAlignment:CrossAxisAlignment.center,
                  mainAxisSize:MainAxisSize.max,
                  children:[

                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment:Alignment(-0.8, 0.0),
                        child:Text(
                          "Cholesterol",
                          textAlign: TextAlign.start,
                          overflow:TextOverflow.clip,
                          style:TextStyle(
                            fontWeight:FontWeight.w600,
                            fontStyle:FontStyle.normal,
                            fontSize:14,
                            color:Color(0xff000000),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment:Alignment(-0.8, 0.0),
                        child:Text(
                          "Sodium",
                          textAlign: TextAlign.start,
                          overflow:TextOverflow.clip,
                          style:TextStyle(
                            fontWeight:FontWeight.w600,
                            fontStyle:FontStyle.normal,
                            fontSize:14,
                            color:Color(0xff000000),
                          ),
                        ),
                      ),
                    ),
                  ],),
                Padding(
                  padding:EdgeInsets.fromLTRB(5, 30, 5, 0),
                  child:Row(
                    mainAxisAlignment:MainAxisAlignment.start,
                    crossAxisAlignment:CrossAxisAlignment.center,
                    mainAxisSize:MainAxisSize.max,
                    children:[

                      Expanded(
                        flex: 1,
                        child: LinearProgressIndicator(
                            backgroundColor: Color(0xff808080),
                            valueColor: new AlwaysStoppedAnimation<Color>(Color(0xff3a57e8)),
                            value: 0.5,
                            minHeight: 5
                        ),
                      ),
                      Text(
                        "                                     ",
                        textAlign: TextAlign.start,
                        overflow:TextOverflow.clip,
                        style:TextStyle(
                          fontWeight:FontWeight.w400,
                          fontStyle:FontStyle.normal,
                          fontSize:14,
                          color:Color(0xff000000),
                        ),
                      ),
                    ],),),
                Row(
                  mainAxisAlignment:MainAxisAlignment.start,
                  crossAxisAlignment:CrossAxisAlignment.center,
                  mainAxisSize:MainAxisSize.max,
                  children:[

                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment:Alignment(-0.8, 0.0),
                        child:Text(
                          "Sugars",
                          textAlign: TextAlign.start,
                          overflow:TextOverflow.clip,
                          style:TextStyle(
                            fontWeight:FontWeight.w600,
                            fontStyle:FontStyle.normal,
                            fontSize:14,
                            color:Color(0xff000000),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        " ",
                        textAlign: TextAlign.start,
                        overflow:TextOverflow.clip,
                        style:TextStyle(
                          fontWeight:FontWeight.w400,
                          fontStyle:FontStyle.normal,
                          fontSize:14,
                          color:Color(0xff000000),
                        ),
                      ),
                    ),
                  ],),*/
              ],),),
        ),
      ),
    )
    ;
  }
}
