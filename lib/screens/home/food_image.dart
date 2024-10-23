
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/database.dart';
import 'home.dart';

class CapturedImage extends StatefulWidget {
  final String imageUrl;
  final String nutriScore;
  final String foodNames;
  final List<dynamic> nutrients;
  final String feedback;
  const CapturedImage({super.key, required this.imageUrl, required this.nutriScore, required this.foodNames, required this.nutrients, required this.feedback});

  @override
  State<CapturedImage> createState() => _CaptureState();
}

class _CaptureState extends State<CapturedImage> {


  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var sections = widget.feedback.split("\n");

    return Scaffold(
        appBar: AppBar(
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0),
            decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(5)
            ),
            child: const Text("NutriTrack"),
          ),

          backgroundColor: Colors.green,
          elevation: 10,
        ),
        body: Container(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            child: SingleChildScrollView(
              child: Column(
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
                          child: Image.network(widget.imageUrl),
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
                      Text(widget.foodNames, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
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
                        Text(widget.nutriScore, style: Theme.of(context).textTheme.labelLarge,),
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
                        child: Text("${widget.nutrients[0]} kJ", style: Theme.of(context).textTheme.bodyMedium,),
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
                        child: Text("${widget.nutrients[1]} g", style: Theme.of(context).textTheme.bodyMedium,),
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
                        child: Text("${widget.nutrients[2]} g", style: Theme.of(context).textTheme.bodyMedium,),
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
                        child: Text("${widget.nutrients[3]} mg", style: Theme.of(context).textTheme.bodyMedium,),
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
                        child: Text("${widget.nutrients[4]} g", style: Theme.of(context).textTheme.bodyMedium,),
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
                        child: Text("${widget.nutrients[5]} g", style: Theme.of(context).textTheme.bodyMedium,),
                      ),
                    ),
                  ),

                  SizedBox(height: 20,),

                  Divider(color: Colors.greenAccent, height: 1.0,),

                  SizedBox(
                    height: 20,
                  ),

                  Column(
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
                    ],
                  )
                ],
              ),

            )));
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
