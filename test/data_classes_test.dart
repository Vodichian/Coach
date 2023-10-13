import 'dart:convert';

import 'package:coach/database/health_record.dart';
import 'package:coach/database/profile.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

void main() {
  test('Test HealthRecord', () {
    Uuid uuid = const Uuid();
    String id = uuid.v1();
    String profileId = uuid.v1();
    DateTime date = DateTime.now();
    double weight = 80;
    HealthRecord record = HealthRecord(id, date, weight, profileId);
    var result = HealthRecord.toJson(record);

    HealthRecord rebuilt = HealthRecord.fromJson(result);

    expect(rebuilt, record);

    // modify a parameter and expect not equal
    rebuilt.bmi = rebuilt.bmi + 1;
    expect(rebuilt, isNot(record));
    logger.i("HealthRecord test finished without errors.");
  });

  test('Testing Profile', () {
    Uuid uuid = const Uuid();
    String id = uuid.v1();
    DateTime date = DateTime.now();
    String name = "My name";
    Gender gender = Gender.male;

    Profile profile = Profile(id, name, date, gender);
    var result = Profile.toJson(profile);

    Profile rebuilt = Profile.fromJson(result);
    expect(rebuilt, profile);

    // modify a parameter and expect not equal
    rebuilt.gender = Gender.female;
    expect(rebuilt, isNot(profile));

    final List<Profile> profiles = [];
    profiles.add(rebuilt);
    profiles.add(profile);

    String jsonString = json.encode(
      profiles,
      toEncodable: (object) => Profile.toJson(object),
    );

    List decodedList = jsonDecode(
      jsonString,
      reviver: (key, value) {
        if (value is Map<String, dynamic>) {
          return Profile.fromJson(value);
        }
        return value;
      },
    );

    expect(profiles, decodedList);

    logger.i("Profile test finished without errors");
  });
}
