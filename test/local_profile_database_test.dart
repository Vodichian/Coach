import 'dart:io';

import 'package:coach/database/local_profile_database.dart';
import 'package:coach/database/no_such_profile_exception.dart';
import 'package:coach/database/profile.dart';
import 'package:logger/logger.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() {
  var logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );
  late LocalProfileDatabase database;
  final Directory testDirectory = Directory.systemTemp.createTempSync();
  final File profileFile =
      File(p.join(testDirectory.absolute.path, 'profiles.json'));

  setUp(() {
    database = LocalProfileDatabase(profileFile);
    database.addListener(wasFired);
    receivedCount = 0; // reset notification count
  });

  tearDown(() {
    database.clear();
    receivedCount = 0;
  });

  test('Profiles can be added to the database', () {
    String name = "My Name";
    DateTime birthday = DateTime.utc(1970);
    Gender gender = Gender.male;
    Profile result = database.add(name, birthday, gender);

    expect(result.name, name);
    expect(result.gender, gender);
    expect(result.birthday, birthday);

    Profile profile = database.findByName(name);
    expect(profile, result);
    expect(receivedCount, 1);
  });

  test('Profiles can be removed from the database', () {
    String name = "rick";
    DateTime birthday = DateTime(1970);
    Gender gender = Gender.male;
    Profile profile1 = database.add(name, birthday, gender);
    database.add("linh", birthday.add(const Duration(days: 1)), gender);
    database.add("tori", birthday.add(const Duration(days: 2)), gender);

    expect(database.profiles().length, 3);
    expect(receivedCount, 3);

    database.remove(profile1);
    expect(database.profiles().length, 2);
    expect(receivedCount, 4);

    // remove it again, expect NoSuchProfile
    bool wasCaught = false;
    try {
      database.remove(profile1);
    } on NoSuchProfileException {
      logger.i("Expected exception caught");
      wasCaught = true;
    } finally {
      expect(wasCaught, true,
          reason: "Should have thrown NoSuchProfile exception");
      expect(database.profiles().length, 2); // unchanged
      expect(receivedCount, 4); // unchanged
    }
  });

  test('Profiles can be updated in the database', () {
    String name = "Another name";
    DateTime birthday = DateTime(1970);
    Gender gender = Gender.male;
    Profile profile1 = database.add(name, birthday, gender);
    expect(database.profiles().length, 1);
    expect(receivedCount, 1);

    profile1.gender = Gender.female;
    database.update(profile1);
    Profile updatedProfile = database.findById(profile1.id);
    expect(profile1.gender, updatedProfile.gender);
    expect(receivedCount, 2);
  });

  test('The database can correctly provide the "current" profile in use.', () {
    /// Algorithm:
    /// 1) Start with empty database
    /// 2) Verify database.currentProfile() throws NoSuchProfileException
    /// 3) Add a profile, verify database.currentProfile() returns this profile
    /// 4) Add another profile, verify database.currentProfile() still returns first profile
    /// 5) Call database.makeProfileCurrent on 2nd profile, verify it now returns as current
    /// 6) Call database.makeProfileCurrent on 1st profile, verify it now returns as current
    /// 7) Remove 1st profile, verify 2nd profile now returns as current

    // Step 2
    bool wasCaught = false;
    try {
      database.currentProfile();
    } on NoSuchProfileException {
      wasCaught = true;
    }
    expect(wasCaught, true);

    // Step 3
    Profile first = database.add("first", DateTime.now(), Gender.male);
    Profile current = database.currentProfile();
    expect(current, first);

    // Step 4
    Profile second = database.add("second", DateTime.now(), Gender.female);
    expect(first, isNot(second));
    current = database.currentProfile();
    expect(current, first);

    // Step 5
    database.makeProfileCurrent(second);
    current = database.currentProfile();
    expect(current, second);

    // Step 6
    database.makeProfileCurrent(first);
    current = database.currentProfile();
    expect(current, first);

    // Step 7
    database.remove(first);
    current = database.currentProfile();
    expect(current, second);
  });
}

var receivedCount = 0; // the number of notifications received

void wasFired() {
  receivedCount++;
}
