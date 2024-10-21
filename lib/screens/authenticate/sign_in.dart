// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Nutritrack/services/auth.dart';
import 'package:Nutritrack/shared/constants.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SignIn extends StatefulWidget {

  final Function toggleView;
  const SignIn({super.key,  required this.toggleView });

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  // Text Field States
  String email = '';
  String password = '';
  String signInError = '';


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
                    const Text("Welcome Back to"),
                    const SizedBox(width: 10.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                      decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(5)
                      ),
                      child: const Text("NutriTrack"),
                    )
                  ],
                ),
                Container(
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 20.0),
                          TextFormField(
                            decoration: textInputDecoration.copyWith(hintText: "Email"),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return "Enter Email";
                              }
                              return null;
                            },
                            onChanged: (val) {
                              setState(() => email = val);
                            },
                          ),
                          const SizedBox(height: 20.0),
                          TextFormField(
                            decoration: textInputDecoration.copyWith(hintText: "Password"),
                            validator: (val) {
                              if (val!.length < 6 || val.isEmpty) {
                                return "Password must be at least 6 characters long";
                              }
                              return null;
                            },
                            obscureText: true,
                            onChanged: (val) {
                              setState(() => password = val);
                            },
                          ),
                          const SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton(
                                style: ButtonStyle(
                                  foregroundColor: WidgetStateProperty.all<Color>(Colors.green),
                                  overlayColor: WidgetStateProperty.all<Color>(Colors.amber),
                                  // padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    dynamic result = await _auth.signInWithEmailAndPass(email, password);
                                    if (result == null) {
                                      setState(() => signInError = "Incorrect email or password");
                                    }
                                  }
                                },
                                child: const Text("Sign In"),
                              ),
                              // SizedBox(width: ),
                              IconButton.outlined(
                                icon: Icon(MdiIcons.fromString("incognito")),
                                style: ButtonStyle(
                                  foregroundColor: WidgetStateProperty.all<Color>(Colors.green),
                                  overlayColor: WidgetStateProperty.all<Color>(Colors.amber),
                                  // padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
                                ),
                                onPressed: () async {
                                  dynamic result = await _auth.signInAnon();
                                  if (result == null) {
                                    setState(() => signInError = "Incorrect email or password");
                                  }
                                },
                              )
                            ],
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            signInError,
                            style: const TextStyle(color: Colors.red, fontSize: 14.0),
                          ),
                          const SizedBox(height: 20.0),
                          const Text("Don't have an account?"),
                          const SizedBox(height: 5.0),
                          OutlinedButton(
                              style: ButtonStyle(
                                foregroundColor: WidgetStateProperty.all<Color>(Colors.green),
                                overlayColor: WidgetStateProperty.all<Color>(Colors.amber),
                              ),
                              onPressed: () {
                                Future.delayed(const Duration(milliseconds: 300), () {
                                  widget.toggleView();
                                });
                              },
                              child: const Text("Register Here!")
                          ),
                        ],
                      ),
                    )

                    // ElevatedButton(
                    //   child: Text("Incognito Mode"),
                    //   onPressed: () async {
                    //     dynamic result = await _auth.signInAnon();
                    //     if (result == null) {
                    //       print("Sign In Error");
                    //     } else {
                    //       print("Signed In");
                    //       print(result.uid);
                    //     }
                    //   }
                    // )
                )
              ],
            )
        )
    );
  }
}
