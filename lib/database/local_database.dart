import 'dart:io';

import 'package:coach/database/database.dart';
import 'package:coach/database/health_record.dart';
import 'package:coach/database/no_such_record_exception.dart';
import 'package:coach/database/profile.dart';
import 'package:coach/database/profile_database.dart';
import 'package:coach/import.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'local_profile_database.dart';

/// LocalDatabase
///
/// This class is a work in progress, mostly pieced together with functionality
/// as I discovered I needed it while developing the application. A great deal of
/// refactoring will be required down the road - 9/10/23 Rick
class LocalDatabase extends ChangeNotifier implements Database {
  final List<HealthRecord> healthRecords = [];
  var allRecords = <Profile, List<HealthRecord>>{}; // TODO: 10/9/2023 Finish creating this map
  final ProfileDatabase profileDatabase = LocalProfileDatabase();
  
  LocalDatabase() {
    // Load database files into memory
    
  }
  
  Future<String> get _localSupportPath async {
    final directory = await getApplicationSupportDirectory();
    return directory.path;
  }
  
  Future<File> get _localDatabaseFile async {
    final path = await _localSupportPath;
    return File('$path/database');
  }
  
  Future<File> _persist() async {
    final file = await _localDatabaseFile;
    return file.writeAsBytes(allRecords.to)
  }

  Profile get currentProfile => profileDatabase.currentProfile();

  // TODO: 10/9/2023 here for testing purposes, to be removed 
  void initialize() {
    final File dataFile =
        File('C:\\Users\\Rick\\Nextcloud\\BodyComposition_202307-202309.csv');
    Importer(this).loadFile(dataFile, currentProfile);
    notifyListeners();
  }

  @override
  Profile makeProfile(String name) {
    // TODO: implement makeProfile
    throw UnimplementedError();
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
    // TODO: implement profiles
    throw UnimplementedError();
  }

  @override
  List<HealthRecord> records(Profile profile) {
    // TODO: implement records
    throw UnimplementedError();
  }

  @override
  void removeProfile(Profile profile) {
    // TODO: implement removeProfile
  }

  @override
  void removeRecord(HealthRecord record) {
    // TODO: implement removeRecord
  }

  @override
  Profile updateProfile(Profile profile) {
    // TODO: implement updateProfile
    throw UnimplementedError();
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
}
