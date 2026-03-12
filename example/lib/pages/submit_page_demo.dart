import 'package:flutter/material.dart';
import 'package:flutty_state/flutty_state.dart';

import '../data/fake_repository.dart';

class SubmitPageDemo extends StatefulWidget {
  const SubmitPageDemo({super.key});

  @override
  State<SubmitPageDemo> createState() => _SubmitPageDemoState();
}

class _SubmitPageDemoState extends State<SubmitPageDemo> {
  final _controller = TextEditingController();
  final _repo = FakeRepository();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SubmitPage(
      appBarBuilder: (_, __, ___) => AppBar(title: const Text('SubmitPage')),
      childBuilder: (submitCubit, context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter a value and submit:'),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Value',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => submitCubit.submit(
                dataSubmitter: () => _repo.saveValue(_controller.text),
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
