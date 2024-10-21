import 'package:Nutritrack/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FoodNotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      body: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.network(
                "https://assets10.lottiefiles.com/packages/lf20_mxuufmel.json",
                height: 200,
                width: 200,
                fit: BoxFit.cover,
                repeat: true,
                animate: true,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 30, 0, 16),
                child: Text(
                  "Error Fetching Product!",
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    fontSize: 20,
                    color: Color(0xff3e3e3e),
                  ),
                ),
              ),
              const Text(
                "There was either no product based on the barcode you scanned or an error in our API services. Please retry your scan or try again at another time. Sorry!",
                textAlign: TextAlign.center,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 16,
                  color: Color(0xff848484),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 30, 0, 16),
                child: MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, "/home");
                    // Navigator.pop(context);
                  },
                  color: Colors.greenAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                  textColor: Color(0xffffffff),
                  height: 45,
                  child: const Text(
                    "Go Back",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
