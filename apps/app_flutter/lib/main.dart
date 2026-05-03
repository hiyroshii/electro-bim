// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 29 04 2026
// - ADD: entry point com MaterialApp e CanvasView

import 'package:flutter/material.dart';
import 'features/canvas/view/canvas_view.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ElectroBIM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Scaffold(body: CanvasView()),
    );
  }
}
