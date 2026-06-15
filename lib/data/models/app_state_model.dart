import 'package:isar/isar.dart';

part 'app_state_model.g.dart';

@collection
class AppStateModel {
  Id id = 0;

  bool onboardingCompleted = false;
  DateTime? lastModified;
  String? preferredLocale; // null means use device locale
}
