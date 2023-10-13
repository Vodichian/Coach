import 'dart:convert';
import 'dart:io';

import 'package:coach/database/database.dart';
import 'package:coach/database/database_exception.dart';
import 'package:coach/database/health_record.dart';
import 'package:coach/database/no_such_record_exception.dart';
import 'package:coach/database/profile.dart';
import 'package:coach/database/profile_database.dart';
import 'package:coach/import.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
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

  final List<HealthRecord> _healthRecords = [];
  late final ProfileDatabase _profileDatabase;
  late final File _recordsFile;
  final Uuid uuid = const Uuid();

  LocalDatabase(Directory directory) {
    String profilesPath = p.join(directory.absolute.path, 'profiles.json');
    File profilesFile = File(profilesPath);
    logger.d("Loading profile database at $profilesPath");
    _profileDatabase = LocalProfileDatabase(profilesFile);

    String recordsPath = p.join(directory.absolute.path, 'records.json');
    _recordsFile = File(recordsPath);
    logger.d("Setting database location to $recordsPath");
    _load();
  }

  void _load() {
    _healthRecords.clear();

    if (_recordsFile.existsSync()) {
      final contents = _recordsFile.readAsStringSync();

      if (contents.isEmpty) return;

      List decodedList = jsonDecode(
        contents,
        reviver: (key, value) {
          if (value is Map<String, dynamic>) {
            return HealthRecord.fromJson(value);
          }
          return value;
        },
      );

      for (var element in decodedList) {
        _healthRecords.add(element);
      }
    }

    notifyListeners();
  }

  void _persist() {
    String recordString = json.encode(_healthRecords,
        toEncodable: (object) => HealthRecord.toJson(object));
    _recordsFile.writeAsStringSync(recordString);
    notifyListeners();
  }

  @override
  Profile currentProfile() {
    return _profileDatabase.currentProfile();
  }

  @override
  void import(File importFile, Profile profile) {
    var results = Importer(this).loadFile(importFile, profile);
    logger.d('Database> imported ${results.length} records into the database');
    // TODO: 10/13/2023 Do I need a notifyListeners call here?
  }

  @override
  Profile makeProfile(String name) {
    return _profileDatabase.add(name, DateTime.now(), Gender.male);
  }

  @override
  HealthRecord makeRecord(DateTime date, double weight, Profile profile) {
    try {
      _findByDateWeightProfile(date, weight, profile);
      throw DatabaseException("A record with the parameters [$date - $weight - ${profile.name}] already exists");
    } on NoSuchRecordException {
      // doesn't exist, make a new record
      HealthRecord record = HealthRecord(uuid.v1(), date, weight, profile.id);
      _healthRecords.add(record);
      _persist();
      return record;
    }
  }

  @override
  List<Profile> profiles() {
    return _profileDatabase.profiles();
  }

  @override
  List<HealthRecord> records(Profile profile) {
    Profile actual = _profileDatabase.findById(profile.id);
    return _healthRecords
        .where((element) => element.profileId == actual.id)
        .toList();
  }

  @override
  void removeProfile(Profile profile) {
    var recordsToDelete = records(_profileDatabase.findById(profile.id));
    if (recordsToDelete.isNotEmpty) {
      for (var element in recordsToDelete) {
        _healthRecords.remove(element);
      }
      _persist();
    }
    _profileDatabase.remove(profile);
  }

  @override
  void removeRecord(HealthRecord record) {
    _healthRecords.remove(_findRecord(record));
    _persist();
  }

  /// Returns matching record from the database
  ///
  /// Throws [NoSuchRecordException] if not found
  /// Throws [StateError} if more than one match is found
  HealthRecord _findRecord(HealthRecord record) {
    try {
      HealthRecord found = _healthRecords.singleWhere(
          (element) => record == element,
          orElse: () => throw NoSuchRecordException("Record not found"));
      return found;
    } on StateError {
      throw DatabaseException(
          "More than one match found, database is corrupted");
    }
  }

  @override
  void updateProfile(Profile profile) {
    _profileDatabase.update(profile);
  }

  @override
  HealthRecord updateRecord(HealthRecord record) {
    HealthRecord found = _findRecord(record);
    found.copyFrom(record);
    _persist();
    return found;
  }

  HealthRecord _findByDateWeightProfile(
      DateTime date, double weight, Profile profile) {
    List<HealthRecord> profileRecords = records(profile);

    try {
      HealthRecord record = profileRecords.singleWhere(
          (element) => element.date == date && element.weight == weight,
          orElse: () {
        throw NoSuchRecordException(
            "Record not found with $date, $weight, and $profile");
      });
      return record;
    } on StateError {
      throw DatabaseException(
          "More than one match found, database is corrupted");
    }
  }

  /// Clear the existing [Profile] objects from the database.
  ///
  /// Intended for testing, use with caution. **Does not clear [HealthRecord] data.**
  void _clearProfiles() {
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

  /// Clear all [HealthRecord] and [Profile]
  ///
  /// Intended for testing, use with caution.
  void clear() {
    _clearProfiles();
    _healthRecords.clear();
    _persist();
  }

  @override
  List<HealthRecord> allRecords() {
    return _healthRecords.toList();
  }
}
