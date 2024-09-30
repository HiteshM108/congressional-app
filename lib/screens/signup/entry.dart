import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  home: StartScreen(),
));

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Welcome to"),
                    SizedBox(width: 10.0),
                    Container(
                      child: Text("NutriTrack"),
                      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                      decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(5)
                      ),
                    )
                  ],
                ),
                SizedBox(height: 25.0),
                ElevatedButton(
                  onPressed: () {},
                  child: Text("Get Started"),

                )
              ],
            )
        )
    );
  }
}
