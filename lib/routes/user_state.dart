import 'package:flutter/foundation.dart';

/// Holds currently logged-in user's info for reactive widgets.
class UserState {
  UserState._();
  static final ValueNotifier<String> name = ValueNotifier<String>('');
  static final ValueNotifier<String> email = ValueNotifier<String>('');
}
