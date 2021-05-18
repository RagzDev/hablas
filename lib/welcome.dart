import 'package:Hablas/constants.dart';

import 'package:Hablas/tabs.dart';

import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Screen 1',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kBackgroundColor,
        textTheme: TextTheme(
          display1: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          button: TextStyle(color: kPrimaryColor),
          headline:
              TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
        ),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white.withOpacity(.2),
            ),
          ),
        ),
      ),
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
              flex: 3,
              child: Center(
                child: Container(
                  height: 400,
                  width: 400,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/1.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Hablas\n",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: "A Text To Speech App",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                        ),
                      )
                    ],
                  ),
                ),
                FittedBox(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return Hablas();
                        },
                      ));
                    },
                    child: Container(
                      height: 41,
                      width: 120,
                      // margin: EdgeInsets.only(bottom: 25),
                      padding: EdgeInsets.symmetric(
                        horizontal: 26,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: kPrimaryColor,
                      ),
                      child: Row(
                        children: <Widget>[
                          Text("START",
                              style: TextStyle(
                                  color: Colors.black, fontSize: 15.0)),
                          SizedBox(width: 0),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.black,
                            size: 15,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
