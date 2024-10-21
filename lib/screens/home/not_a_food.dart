import 'dart:io';
import 'package:flutter/material.dart';


class NotAFood extends StatelessWidget {
  const NotAFood(this.image, {super.key});

  final String image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffffffff),
        body:Container(
            margin: EdgeInsets.all(0),
            padding: EdgeInsets.all(0),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(child:
            Align(
              alignment:Alignment.center,
              child:Padding(
                padding:EdgeInsets.all(0),
                child:
                Column(
                  mainAxisAlignment:MainAxisAlignment.center,
                  crossAxisAlignment:CrossAxisAlignment.center,
                  mainAxisSize:MainAxisSize.max,
                  children: [
                    Image.file(
                      (File(image)),
                      // image:NetworkImage("https://image.freepik.com/free-vector/no-data-concept-illustration_114360-2506.jpg"),
                      fit:BoxFit.cover,
                    ),
                    Padding(
                      padding:EdgeInsets.fromLTRB(0, 16, 0, 0),
                      child:Text(
                        "Image Not a Food!",
                        textAlign: TextAlign.start,
                        overflow:TextOverflow.clip,
                        style:TextStyle(
                          fontWeight:FontWeight.w700,
                          fontStyle:FontStyle.normal,
                          fontSize:30,
                          color:Color(0xff000000),
                        ),
                      ),
                    ),
                    Padding(
                      padding:EdgeInsets.fromLTRB(0, 50, 0, 0),
                      child:MaterialButton(
                        onPressed:(){
                          // Navigator.popAndPushNamed(context, "/home");
                          Navigator.pop(context);
                        },
                        color:Color(0xff3a57e8),
                        elevation:0,
                        shape:RoundedRectangleBorder(
                          borderRadius:BorderRadius.circular(26.0),
                        ),
                        padding:EdgeInsets.all(16),
                        child:Text("Retake", style: TextStyle( fontSize:16,
                          fontWeight:FontWeight.w400,
                          fontStyle:FontStyle.normal,
                        ),),
                        textColor:Color(0xffffffff),
                        height:45,
                        minWidth:MediaQuery.of(context).size.width * 0.6,
                      ),
                    ),
                  ],),),),
            )));}
}