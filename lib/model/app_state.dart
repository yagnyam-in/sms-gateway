import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  final FirebaseUser firebaseUser;
  final SharedPreferences sharedPreferences;

  AppState({this.firebaseUser, this.sharedPreferences}) {
    assert(sharedPreferences != null);
  }

  AppState login(FirebaseUser firebaseUser) {
    assert(firebaseUser != null);
    return AppState(
      firebaseUser: firebaseUser,
      sharedPreferences: sharedPreferences,
    );
  }

  AppState logout() {
    return AppState(
      firebaseUser: null,
      sharedPreferences: sharedPreferences,
    );
  }

  String get userId => firebaseUser?.uid;
}
