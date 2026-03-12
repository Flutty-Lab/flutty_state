import 'package:flutter/material.dart';

import 'fetch_and_submit_demo.dart';
import 'static_page_demo.dart';
import 'submit_page_demo.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('flutty_state demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StaticPageDemo()),
            ),
            child: const Text('StaticPage'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SubmitPageDemo()),
            ),
            child: const Text('SubmitPage'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FetchAndSubmitDemo()),
            ),
            child: const Text('FetchAndSubmitPage'),
          ),
        ],
      ),
    );
  }
}
