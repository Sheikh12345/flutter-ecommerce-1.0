import 'dart:ui';

import 'package:flutter/material.dart';

class ThankYou extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        popBackStackToHome(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Order Placed"),
        ),
        body: Container(
          margin: EdgeInsets.all(16.0),
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: IconTheme(
                    data: IconThemeData(color: Colors.green[800]),
                    child: Icon(Icons.assignment_turned_in, size: 100.0,)),
              ),
              Text("Thank you", style: TextStyle(fontSize: 21.0, fontWeight: FontWeight.bold),),
              SizedBox(height: 4.0,),
              Text("Thank you for shopping with us!"),
              SizedBox(height: 8.0,),
              FlatButton(
                color: Colors.green[800],
                child: Text("CONTINUE SHOPPING", style: TextStyle(color: Colors.white),),
                onPressed: () {
                  popBackStackToHome(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void popBackStackToHome(BuildContext context) {
    int count = 0;
    Navigator.popUntil(context, (route) {
      return count++ == 6;
    });
  }
}
