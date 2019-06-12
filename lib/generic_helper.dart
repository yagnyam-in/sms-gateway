typedef AsyncFunction<T> = Future<T> Function();

mixin GenericHelper {
  Future<void> ignoreErrors<T>(AsyncFunction<T> function) async {
    try {
      await function();
    } catch (e) {
      print("Error $e");
    }
  }
}
