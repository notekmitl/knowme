import 'package:flutter/material.dart';

class EqResultPage extends StatelessWidget {
  final Map<String, double> traits;

  const EqResultPage({super.key, required this.traits});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("EQ Result")),

      body: Center(child: Text(traits.toString())),
    );
  }
}
