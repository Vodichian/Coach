import 'dart:io';

import 'package:coach/database/database.dart';
import 'package:coach/database/health_record.dart';
import 'package:coach/database/no_such_record_exception.dart';
import 'package:coach/database/profile.dart';
import 'package:coach/database/profile_database.dart';
import 'package:coach/import.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'local_profile_database.dart';
import 'package:path/path.dart' as p;

/// LocalDatabase
///
/// This class is a work in progress, mostly pieced together with functionality
/// as I discovered I needed it while developing the application. A great deal of
/// refactoring will be required down the road - 9/10/23 Rick
class LocalDatabase extends ChangeNotifier implements Database {
  var logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  final List<HealthRecord> healthRecords = [];
  var allRecords = <Profile,
      List<HealthRecord>>{}; // TODO: 10/9/2023 Finish creating this map
  late final ProfileDatabase _profileDatabase;
  late final File recordsFile;

  LocalDatabase(Directory directory) {
    String profilesPath = p.join(directory.absolute.path, 'profiles.json');
    File profilesFile = File(profilesPath);
    logger.d("Loading profile database at $profilesPath");
    _profileDatabase = LocalProfileDatabase(profilesFile);

    String recordsPath = p.join(directory.absolute.path, 'records.json');
    recordsFile = File(recordsPath);
    logger.d("Setting database location to $recordsPath");
  }

  Future<File> _persist() async {
    throw UnimplementedError();
  }

  Profile get currentProfile => _profileDatabase.currentProfile();

  // TODO: 10/9/2023 here for testing purposes, to be removed
  void initialize() {
    final File dataFile =
        File('C:\\Users\\Rick\\Nextcloud\\BodyComposition_202307-202309.csv');
    Importer(this).loadFile(dataFile, currentProfile);
    notifyListeners();
  }

  @override
  Profile makeProfile(String name) {
    return _profileDatabase.add(name, DateTime.now(), Gender.male);
  }

  @override
  HealthRecord makeRecord(DateTime date, double weight, Profile profile) {
    try {
      HealthRecord found = findByDateWeightProfile(date, weight, profile);
    } on StateError {
      // more than 1 match found, this should never happen
    } on NoSuchRecordException {
      // doesn't exist, make a new record
      HealthRecord record = HealthRecord(profile.id, date, weight);
    }
    throw UnimplementedError();
  }

  @override
  List<Profile> profiles() {
    return _profileDatabase.profiles();
  }

  @override
  List<HealthRecord> records(Profile profile) {
    // TODO: implement records
    throw UnimplementedError();
  }

  @override
  void removeProfile(Profile profile) {
    _profileDatabase.remove(profile);
  }

  @override
  void removeRecord(HealthRecord record) {
    // TODO: implement removeRecord
  }

  @override
  void updateProfile(Profile profile) {
    _profileDatabase.update(profile);
  }

  @override
  HealthRecord updateRecord(HealthRecord record, Profile profile) {
    // TODO: implement updateRecord
    throw UnimplementedError();
  }

  HealthRecord findByDateWeightProfile(
      DateTime date, double weight, Profile profile) {
    List<HealthRecord> profileRecords = records(profile);
    if (profileRecords.isEmpty) {
      throw NoSuchRecordException(
          "Record not found with $date, $weight, and $profile");
    }

    return profileRecords.singleWhere(
        (element) => element.date == date && element.weight == weight,
        orElse: () {
      throw NoSuchRecordException("No matching record was found");
    });
  }

  void clearProfiles() {
    if (_profileDatabase is LocalProfileDatabase) {
      (_profileDatabase as LocalProfileDatabase).clear();
    } else {
      throw UnsupportedError(
          "clearProfiles not supported for installed profile database");
    }
  }

  @override
  void makeProfileCurrent(Profile profile) {
    _profileDatabase.makeProfileCurrent(profile);
  }

  @override
  void addListener(VoidCallback listener) {
    _profileDatabase.addListener(listener);
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _profileDatabase.removeListener(listener);
    super.removeListener(listener);
  }
}
