import 'package:flutter/material.dart';
import 'package:flutty_state/flutty_state.dart';

import '../data/fake_repository.dart';

class FetchAndSubmitDemo extends StatefulWidget {
  const FetchAndSubmitDemo({super.key});

  @override
  State<FetchAndSubmitDemo> createState() => _FetchAndSubmitDemoState();
}

class _FetchAndSubmitDemoState extends State<FetchAndSubmitDemo> {
  final _repo = FakeRepository();

  @override
  Widget build(BuildContext context) {
    return FetchAndSubmitPage<Profile>(
      appBarBuilder: (data, _, __) => AppBar(
        title: Text(data == null ? 'Loading…' : 'Hello ${data.name}'),
      ),
      dataFetcher: _repo.fetchProfile,
      builder: (data, submitCubit, context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${data.name}'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => submitCubit.submitAndFetch(
                dataSubmitter: () => _repo.incrementCounter(),
              ),
              child: Text('Increment counter (${data.counter})'),
            ),
          ],
        );
      },
    );
  }
}
