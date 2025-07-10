import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox("MY_BOX");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToDoApp',
      theme: ThemeData(
          brightness: Brightness.dark, colorSchemeSeed: Colors.blue[900]),
      home: HomePage(),
    );
  }
}
