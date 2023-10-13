import 'package:coach/database/no_such_profile_exception.dart';
import 'package:coach/database/no_such_record_exception.dart';
import 'package:coach/database/profile.dart';
import 'package:flutter/foundation.dart';

import 'health_record.dart';

/// Database interface

abstract class Database extends ChangeNotifier {
  /// Return a list of all [HealthRecord] associated with [profile]
  ///
  /// Returns an empty list if no records are found.
  /// Throws [NoSuchProfileException] if [profile] does not exist.
  List<HealthRecord> records(Profile profile);

  /// Returns a [HealthRecord] using the provided parameters
  ///
  /// Returns an existing [HealthRecord] if an identical match is found for the
  /// given parameters, otherwise returns a newly created and persisted [HealthRecord]
  HealthRecord makeRecord(DateTime date, double weight, Profile profile);

  /// Removes [record] from the database.
  ///
  /// Throws [NoSuchRecordException] if [record] is not found.
  void removeRecord(HealthRecord record);

  /// Persists the modifications made to [record].
  ///
  /// Throws [NoSuchRecordException] if [record] is not found.
  HealthRecord updateRecord(HealthRecord record);

  /// Return a list of all persisted profiles.
  List<Profile> profiles();

  /// Add a new [Profile]
  Profile makeProfile(String name);

  /// Removes [profile] from the database.
  ///
  /// Removing the [Profile] will also remove all associated [HealthRecord] objects.
  /// Throws [NoSuchProfileException] if [profile] is not found.
  void removeProfile(Profile profile);

  /// Persists the modifications made to [profile].
  ///
  /// Throws [NoSuchProfileException] if [profile] is not found.
  void updateProfile(Profile profile);

  /// Make [profile] the current [Profile]
  void makeProfileCurrent(Profile profile);

  /// Return the current [Profile]
  Profile currentProfile();

  /// Returns all [HealthRecord] objects in the database.
  List<HealthRecord> allRecords();
}
