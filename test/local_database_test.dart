import 'dart:io';
import 'dart:math';

import 'package:coach/database/database_exception.dart';
import 'package:coach/database/health_record.dart';
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
  final Directory testDirectory = Directory.systemTemp.createTempSync();

  setUp(() {
    database = LocalDatabase();
    database.load(testDirectory);
    database.clear();
    notificationCount = 0;
    database.addListener(wasFired);
  });

  test('Database should be able to handle Profile operations', () {
    var profiles = database.profiles();
    expect(profiles.length, 0);

    var wasCaught = false;
    try {
      database.currentProfile();
    } on NoSuchProfileException {
      wasCaught = true;
    }
    expect(wasCaught, true);

    Profile first = database.makeProfile("first");
    Profile second = database.makeProfile("second");
    expect(first.name, "first");
    expect(second.name, "second");
    expect(notificationCount, 2);

    Profile current = database.currentProfile();
    expect(current, first);
    database.makeProfileCurrent(second);
    current = database.currentProfile();
    expect(current, second);
    expect(notificationCount, 3);

    database.removeProfile(second);
    current = database.currentProfile();
    expect(current, first);
    expect(database.profiles().length, 1);
    expect(notificationCount, 4);

    first.birthday = DateTime(1980);
    database.updateProfile(first);
    current = database.currentProfile();
    expect(current.birthday, first.birthday);
    expect(notificationCount, 5);
  });

  test('Database should persist HealthRecords to the filesystem', () {
    logger.d("starting test, creating profile `first`");
    Profile first = database.makeProfile("first");
    database.makeRecord(DateTime.now(), 71, first);
    database.makeRecord(DateTime.now(), 72, first);
    database.makeRecord(DateTime.now(), 73, first);
    List<HealthRecord> records = database.records(first);
    expect(records.length, 3);

    /// Create a new Database loaded from the same file. This will verify the
    /// data has been persisted to the filesystem.
    LocalDatabase testLoadDatabase = LocalDatabase();
    testLoadDatabase.load(testDirectory);
    logger.i("Loading database from: ${testDirectory.absolute.path}");
    Profile current = testLoadDatabase.currentProfile();
    List<HealthRecord> toTestRecords = testLoadDatabase.records(current);
    expect(toTestRecords, records);
  });

  test('Database does not allow duplicate records', () {
    // Duplicate record = same date, same weight, for same profile
    Profile first = database.makeProfile("first");
    DateTime date = DateTime.now();
    double weight = 70.0;
    database.makeRecord(date, weight, first);
    expect(database.records(first).length, 1);
    expect(notificationCount, 2); // profile + record

    var wasCaught = false;
    try {
      database.makeRecord(date, weight, first);
    } on DatabaseException {
      wasCaught = true;
    }
    expect(wasCaught, true);
    expect(database.records(first).length, 1);
    expect(notificationCount, 2);

    database.makeRecord(DateTime.now(), weight, first);
    expect(database.records(first).length, 2);
    expect(notificationCount, 3);

    // Same record, different profile should not throw an exception
    Profile second = database.makeProfile("second");
    database.makeRecord(date, weight, second);
    expect(database.records(first).length, 2);
    expect(database.records(second).length, 1);
    expect(notificationCount, 5); // profile + record
  });

  test('Removing a profile also removes all associated records', () {
    /// Algorithm
    /// Create multiple profiles, each with multiple records
    /// Remove one profile, verify all its records have been removed
    /// Verify existing profile still has all its records.

    Profile first = database.makeProfile("first");
    Profile second = database.makeProfile("second");

    // creating profiles with data
    Random random = Random();
    var firstList = [];
    for (var i = 0; i < 10; i++) {
      firstList
          .add(database.makeRecord(DateTime.now(), random.nextDouble(), first));
    }
    var secondList = [];
    for (var i = 0; i < 10; i++) {
      secondList.add(
          database.makeRecord(DateTime.now(), random.nextDouble(), second));
    }
    expect(firstList.length, greaterThan(0));
    expect(secondList.length, greaterThan(0));
    expect(database.records(first), firstList);
    expect(database.records(second), secondList);
    expect(database.allRecords().length, firstList.length + secondList.length);

    // removing one profile
    database.removeProfile(first);
    var wasCaught = false;
    try {
      database.records(first);
    } on NoSuchProfileException {
      wasCaught = true;
    }
    expect(wasCaught, isTrue);
    List<HealthRecord> allRecords = database.allRecords();
    expect(allRecords.length, secondList.length);
    expect(database.allRecords(), secondList);
  });

  test('A HealthRecord can be updated, removed; all being persisted', () {
    var firstProfile = database.makeProfile("first");
    var record = database.makeRecord(DateTime.now(), 70.0, firstProfile);
    var found = database.records(firstProfile).first;
    expect(found, record);

    record.weight = ++record.weight;

    // not persisted, new database will not see changes
    LocalDatabase secondDatabase = LocalDatabase();
    secondDatabase.load(testDirectory);
    var secondDbProfile = secondDatabase.currentProfile();
    var secondDbRecord = secondDatabase.records(secondDbProfile).first;
    expect(record, isNot(secondDbRecord));

    // now persisted, new database will see changes
    database.updateRecord(record);
    LocalDatabase thirdDatabase = LocalDatabase();
    thirdDatabase.load(testDirectory);
    var thirdDbProfile = thirdDatabase.currentProfile();
    var thirdDbRecord = thirdDatabase.records(thirdDbProfile).first;
    expect(record, thirdDbRecord);

    database.removeRecord(record);
    expect(database.allRecords(), isEmpty);

    LocalDatabase fourthDatabase = LocalDatabase();
    fourthDatabase.load(testDirectory);
    expect(fourthDatabase.allRecords(), isEmpty);
  });

  test('Importing does not allow duplication of existing records', () {
    File dataFile = File('test/resources/BodyComposition_202307-202309.csv');
    expect(dataFile.existsSync(), isTrue);

    expect(database.allRecords(), isEmpty);
    var profile = database.makeProfile("first");
    database.import(dataFile, profile);
    var allRecords = database.allRecords();
    expect(allRecords, isNotEmpty);
    var recordCount = allRecords.length;
    logger.i('$recordCount records have been loaded');

    /// do the import again, verify database remains unmodified
    database.import(dataFile, profile);
    expect(database.allRecords().length, recordCount); // unmodified

    /// add a few records manually, redo import, verify remains unmodified
    database.makeRecord(DateTime.now(), 88, profile);
    database.makeRecord(DateTime.now(), 89, profile);
    database.import(dataFile, profile);
    expect(database.allRecords().length, recordCount + 2); // unmodified

    /// Create a new profile, verify import into it works
    var anotherProfile = database.makeProfile("another");
    database.import(dataFile, anotherProfile);
    expect(database.allRecords().length, (recordCount * 2) + 2);
    expect(database.records(anotherProfile).length, recordCount);
    logger.i(
        'Total number of database notifications received: $notificationCount');
  });

  test('Database should return HealthRecords by Profile', () {
    var firstProfile = database.makeProfile("first");
    var secondProfile = database.makeProfile("second");
    var thirdProfile = database.makeProfile("third");
    var emptyProfile = database.makeProfile("empty");

    Random random = Random();
    var firstList = [];
    for (var i = 0; i < random.nextInt(200) + 1; i++) {
      firstList.add(database.makeRecord(
          DateTime.now(), random.nextDouble(), firstProfile));
    }
    var secondList = [];
    for (var i = 0; i < random.nextInt(200) + 1; i++) {
      secondList.add(database.makeRecord(
          DateTime.now(), random.nextDouble(), secondProfile));
    }
    var thirdList = [];
    for (var i = 0; i < random.nextInt(200) + 1; i++) {
      thirdList.add(database.makeRecord(
          DateTime.now(), random.nextDouble(), thirdProfile));
    }

    logger.i('Database has a total of ${database.allRecords().length} records');
    expect(database.records(firstProfile), firstList);
    expect(database.records(secondProfile), secondList);
    expect(database.records(thirdProfile), thirdList);
    expect(database.records(emptyProfile), isEmpty);

    logger.i(
        'Total number of database notifications received: $notificationCount');
  });
}

var notificationCount = 0; // the number of notifications received

void wasFired() {
  notificationCount++;
}
