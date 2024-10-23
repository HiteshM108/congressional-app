import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:Nutritrack/shared/constants.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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

  String selectedGender = "Male";

  // String activityLevel = "Moderately Active - Walking, light exercise, or sports 3-5 times a week";
  var activityItems = [
    "Sedentary - Little to no physical activity beyond daily tasks",
    "Lightly Active - Casual light exercise a few times a week",
    "Moderately Active - Light exercise 3-5 times a week",
    "Active - Regular physical exercise 5+ days a week",
  ];

  String activityLevel = "";

  // var activityItems = [
  //   "Sedentary - Little to no physical activity beyond daily tasks",
  //   "Lightly Active - Casual light exercise a few times a week"
  //   "Moderately Active - Light exercise 3-5 times a week",
  //   "Active - Regular physical exercise 5+ days a week"
  // ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Please fill out the required user information"),
            const SizedBox(height: 10.0),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration:
                            textInputDecoration.copyWith(hintText: "Name"),
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
                      const SizedBox(height: 15.0),

                      TextFormField(
                        decoration:
                            textInputDecoration.copyWith(hintText: "Age"),
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
                      const SizedBox(height: 15.0),

                      TextFormField(
                        decoration: textInputDecoration.copyWith(
                            hintText: "Weight in Pounds"),
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
                      const SizedBox(height: 15.0),

                      TextFormField(
                        decoration: textInputDecoration.copyWith(
                            hintText: "Height in Inches"),
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

                      const SizedBox(height: 15),

                      // DropdownButton(
                      //   value: activityLevel,
                      //   icon: Icon(MdiIcons.fromString("chevron-down")),
                      //   items: items.map((String items) {
                      //     return DropdownMenuItem(
                      //       value: items,
                      //       child: Text(items),
                      //     );
                      //   }).toList(),
                      //   onChanged: (String? newVal) {
                      //     setState(() {
                      //       activityLevel = newVal!;
                      //     });
                      //   }
                      // ),

                      DropdownButtonFormField2<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          // Add Horizontal padding using menuItemStyleData.padding so it matches
                          // the menu padding when button's width is not specified.
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(color: Colors.amberAccent, width: 2.0)
                          )
                        ),
                        hint: const Text(
                          'Select Your Activity Level',
                          style: TextStyle(fontSize: 14),
                        ),
                        items: activityItems
                            .map((item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                            .toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select an activity level.';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          activityLevel = value.toString();
                        },
                        onSaved: (value) {
                          activityLevel = value.toString();
                        },
                        buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.only(right: 8),
                        ),
                        iconStyleData: IconStyleData(
                          icon: Icon(
                            MdiIcons.fromString("chevron-down"),
                            color: Colors.black45,
                          ),
                          iconSize: 24,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      RadioListTile(
                          title: Row(
                            children: [
                              Icon(MdiIcons.fromString("gender-male")),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text("Male"),
                            ],
                          ),
                          activeColor: Colors.blueAccent,
                          value: "Male",
                          groupValue: selectedGender,
                          onChanged: (String? value) {
                            setState(() {
                              selectedGender = value!;
                            });
                          }),

                      RadioListTile(
                          title: Row(
                            children: [
                              Icon(MdiIcons.fromString("gender-female")),
                              SizedBox(
                                width: 10,
                              ),
                              const Text("Female"),
                            ],
                          ),
                          activeColor: Colors.pinkAccent,
                          value: "Female",
                          groupValue: selectedGender,
                          onChanged: (String? value) {
                            setState(() {
                              selectedGender = value!;
                            });
                          }),

                      const SizedBox(height: 15),
                      OutlinedButton(
                          style: ButtonStyle(
                            foregroundColor: WidgetStateProperty.all<Color>(
                                Colors.green),
                            overlayColor:
                                WidgetStateProperty.all<Color>(Colors.amber),
                            // padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              Navigator.pop(
                                  context, <String>[name, age, weight, height, selectedGender, activityLevel]);
                            }
                          },
                          child: const Text('Complete Registration'))
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
