import 'package:isar/isar.dart';

part 'app_state_model.g.dart';

@collection
class AppStateModel {
  Id id = 0; // Solo un registro único

  bool onboardingCompleted = false;
  DateTime? lastModified;
}
