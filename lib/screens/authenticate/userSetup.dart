import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test_app/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_app/shared/constants.dart';

class UserInfoSetup extends StatefulWidget {
  const UserInfoSetup({super.key});

  @override
  State<UserInfoSetup> createState() => _UserInfoSetupState();
}

class _UserInfoSetupState extends State<UserInfoSetup> {

  final TextEditingController _editNameController = TextEditingController();
  final TextEditingController _editAgeController = TextEditingController();
  final TextEditingController _editWeightController = TextEditingController();
  final TextEditingController _editHeightController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Text Field States
  String name = '';
  String age = '';
  String weight = '';
  String height = '';
  String setupError = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Please fill out the required user information"),
            SizedBox(height: 10.0),
            Container(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: textInputDecoration.copyWith(hintText: "Name"),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Name";
                          }
                          return null;
                        },
                        onChanged: (val) {
                          setState(() => name = val);
                        },
                      ),
                      SizedBox(height: 20.0),

                      TextFormField(
                        decoration: textInputDecoration.copyWith(hintText: "Age"),
                        validator: (val) {
                          try {
                            if (val == null || val.isEmpty) {
                              return "Enter Age";
                            }
                            final input = int.parse(val.toString());
                            return null;
                          } catch (e) {
                            return "Enter a Number";
                          }

                        },
                        onChanged: (val) {
                          setState(() => age = val);
                        },
                      ),
                      SizedBox(height: 20.0),

                      TextFormField(
                        decoration: textInputDecoration.copyWith(hintText: "Weight in Pounds"),
                        validator: (val) {
                          try {
                            if (val == null || val.isEmpty) {
                              return "Enter Weight";
                            }
                            final input = int.parse(val.toString());
                            return null;
                          } catch (e) {
                            return "Enter a Number";
                          }

                        },
                        onChanged: (val) {
                          setState(() => weight = val);
                        },
                      ),
                      SizedBox(height: 20.0),

                      TextFormField(
                        decoration: textInputDecoration.copyWith(hintText: "Height in Inches"),
                        validator: (val) {
                          try {
                            if (val == null || val.isEmpty) {
                              return "Enter Height";
                            }
                            final input = int.parse(val.toString());
                            return null;
                          } catch (e) {
                            return "Enter a Number";
                          }

                        },
                        onChanged: (val) {
                          setState(() => height = val);
                        },
                      ),
                      SizedBox(height: 15),
                      OutlinedButton(
                          style: ButtonStyle(
                            foregroundColor: WidgetStateProperty.all<Color>(Colors.deepPurple),
                            overlayColor: WidgetStateProperty.all<Color>(Colors.amber),
                            // padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              Navigator.pop(context, <String>[name, age, weight, height]);
                            }
                          }, child: const Text('Complete Registration'))
                    ],
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }
}
