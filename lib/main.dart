import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/view/homePage.dart';
import 'package:todo/viewModel/toDoViewmodel.dart';

void main() {
  runApp( MultiProvider(
    providers: [ChangeNotifierProvider(create: (_)=>todoViewModel())],
    child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,home: HomePage(),
    );
  }
}

