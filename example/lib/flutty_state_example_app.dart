import 'package:flutter/material.dart';

import 'pages/home_page.dart';

class FluttyStateExample extends StatelessWidget {
  const FluttyStateExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutty State Example',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
