import 'package:flutter/material.dart';
import 'package:flutty_state/flutty_state.dart';

class StaticPageDemo extends StatelessWidget {
  const StaticPageDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return StaticPage(
      appBar: AppBar(title: const Text('StaticPage')),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('A simple scrollable layout.'),
          SizedBox(height: 12),
          Text(
            'Use it when your screen does not need initial fetching or submission state.',
          ),
        ],
      ),
    );
  }
}
