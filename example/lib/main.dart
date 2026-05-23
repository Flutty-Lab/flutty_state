import 'package:flutter/material.dart';
import 'package:flutty_state/data/data_fetch_response.dart';
import 'package:flutty_state/data/data_submit_response.dart';
import 'package:flutty_state/ui/fetch_and_submit_page.dart';
import 'package:flutty_state/ui/static_page.dart';
import 'package:flutty_state/ui/submit_page.dart';

void main() {
  runApp(const FluttyStateExample());
}

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
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const FetchAndSubmitWithFetchErrorDemo()),
            ),
            child: const Text('FetchAndSubmitPage (fetch error + retry)'),
          ),
        ],
      ),
    );
  }
}

/// StaticPage is a simple scrollable layout. Use it when your screen does not need

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

/// SubmitPage provides a clean layout for forms with built-in submission state handling, loading indicators, and automatic scroll behavior. Ideal for simple forms that don't require initial data fetching.

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
      appBarBuilder: (__, ___) => AppBar(title: const Text('SubmitPage')),
      builder: (submitCubit, context) {
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

/// FetchAndSubmitPage combines the features of both StaticPage and SubmitPage, providing a layout that supports both initial data fetching and subsequent data submission. It handles loading states for both operations, making it ideal for screens that need to display fetched data and allow user interactions that trigger submissions.

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

class FetchAndSubmitWithFetchErrorDemo extends StatefulWidget {
  const FetchAndSubmitWithFetchErrorDemo({super.key});

  @override
  State<FetchAndSubmitWithFetchErrorDemo> createState() =>
      _FetchAndSubmitWithFetchErrorDemoState();
}

class _FetchAndSubmitWithFetchErrorDemoState
    extends State<FetchAndSubmitWithFetchErrorDemo> {
  final _repo = FakeRepository();

  @override
  Widget build(BuildContext context) {
    return FetchAndSubmitPage<Profile>(
      appBarBuilder: (data, _, __) => AppBar(
        title:
            Text(data == null ? 'Fetch error demo' : 'Recovered: ${data.name}'),
      ),
      dataFetcher: _repo.fetchProfileFailOnce,
      fetchFailedBuilder: (failure, retryFetch, context) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Fetch failed: ${failure.failedMessage}'),
              const SizedBox(height: 8),
              const Text('Tap retry to fetch data again.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: retryFetch,
                child: const Text('Retry fetch'),
              ),
            ],
          ),
        );
      },
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

// A simple data model representing a user profile with a name and a counter.

class Profile {
  const Profile({required this.name, required this.counter});

  final String name;
  final int counter;
}

class FakeRepository {
  var _counter = 0;
  var _shouldFailFetchOnce = true;

  Future<DataFetchingResponse<Profile>> fetchProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    return DataFetchSucceed(
      data: Profile(name: 'Flutty', counter: _counter),
    );
  }

  Future<DataFetchingResponse<Profile>> fetchProfileFailOnce() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (_shouldFailFetchOnce) {
      _shouldFailFetchOnce = false;
      return DataFetchFailed(
        message: 'Simulated network error on first fetch',
      );
    }
    return fetchProfile();
  }

  Future<DataSubmitResponse<void>> saveValue(String value) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (value.trim().isEmpty) {
      return DataSubmitFailed(message: 'Please enter a value');
    }
    return DataSubmitSucceedEmpty(message: 'Saved');
  }

  Future<DataSubmitResponse<void>> incrementCounter() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _counter++;
    return DataSubmitSucceedEmpty(message: 'Updated');
  }
}
