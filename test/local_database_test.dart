import 'dart:io';

import 'package:coach/database/local_database.dart';
import 'package:coach/database/no_such_profile_exception.dart';
import 'package:coach/database/profile.dart';
import 'package:logger/logger.dart';
import 'package:test/test.dart';

void main() {
  final Logger logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  late LocalDatabase database;

  setUp(() {
    Directory directory = Directory("");
    logger.d("Directory: ${directory.absolute}");
    database = LocalDatabase(directory);
    database.addListener(wasFired);
  });

  tearDown(() {
    database.clearProfiles();
  });

  test('Database should be able to handle Profile operations', () {
    var profiles = database.profiles();
    expect(profiles.length, 0);

    var wasCaught = false;
    try {
      database.currentProfile;
    } on NoSuchProfileException {
      wasCaught = true;
    }
    expect(wasCaught, true);

    Profile first = database.makeProfile("first");
    Profile second = database.makeProfile("second");
    expect(first.name, "first");
    expect(second.name, "second");
    expect(notificationCount,
        2); // expect 2 notification from the database to have been fired

    Profile current = database.currentProfile;
    expect(current, first);
    database.makeProfileCurrent(second);
    current = database.currentProfile;
    expect(current, second);
    expect(notificationCount, 3);

    database.removeProfile(second);
    current = database.currentProfile;
    expect(current, first);
    expect(database.profiles().length, 1);
    expect(notificationCount, 4);

    first.birthday = DateTime(1980);
    database.updateProfile(first);
    current = database.currentProfile;
    expect(current.birthday, first.birthday);
    expect(notificationCount, 5);
  });
}

var notificationCount = 0; // the number of notifications received

void wasFired() {
  notificationCount++;
}
