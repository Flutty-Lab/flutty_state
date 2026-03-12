import 'dart:async';

abstract class Repository<T> {
  final controller = StreamController<T>();
  Stream<T>? _stream;

  Stream<T> getStream() => _stream ??= controller.stream.asBroadcastStream();

  Future<D> cacheOrCall<D extends List<dynamic>>({
    required D cache,
    required Future<D> Function() get,
  }) async {
    if (cache.isEmpty) {
      return get();
    }

    Future.delayed(const Duration(milliseconds: 10), () async {
      await get();
    });

    return cache;
  }
}
