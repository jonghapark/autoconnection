import 'package:flutter/material.dart';
import 'component/screen_main.dart';

void main() {
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OPTILO',
      theme: ThemeData(
        // primarySwatch: Colors.grey,
        primaryColor: Color.fromRGBO(22, 33, 55, 1),
        //canvasColor: Colors.transparent,
      ),
      home: Scanscreen()));
}
