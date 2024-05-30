import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:statuswa/app_routes.dart';
import 'package:statuswa/floating_action_btn.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // getPages: AppPages.routes(),
      home: FloatingActionBtn(),
    );
  }
}
