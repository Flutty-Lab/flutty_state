import 'package:flutty_state/flutty_state.dart';

class Profile {
  const Profile({required this.name, required this.counter});

  final String name;
  final int counter;
}

class FakeRepository {
  var _counter = 0;

  Future<DataFetchingResponse<Profile>> fetchProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    return DataFetchSucceed(
      data: Profile(name: 'Flutty', counter: _counter),
    );
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
