import 'package:coach/database/profile.dart';
import 'package:flutter/foundation.dart';
import 'no_such_profile_exception.dart';

abstract class ProfileDatabase with ChangeNotifier {
  /// Return a list of all [Profile] objects.
  List<Profile> profiles();

  /// Add a new [Profile]
  Profile add(String name, DateTime birthday, Gender gender);

  /// Returns the profile containing [name].
  ///
  /// Throws [NoSuchProfileException] if no matching [Profile] is found.
  Profile findByName(String name);

  /// Returns the [Profile] with [id].
  ///
  /// Throws [NoSuchProfileException] if no matching [Profile] is found.
  Profile findById(String id);

  /// Determines if a [Profile] exists with the given [name].
  ///
  /// Return <code>true</code> if exists, else <code>false</code>.
  bool exists(String name);

  /// Removes [profile] from the database.
  ///
  /// Throws [NoSuchProfileException] if [profile] is not found.
  void remove(Profile profile);

  /// Persists the modifications made to [profile].
  ///
  /// Throws [NoSuchProfileException] if [profile] is not found.
  void update(Profile profile);

  /// Returns the [Profile] currently in use.
  ///
  /// Throws [NoSuchProfileException] if no profile exists.
  Profile currentProfile();

  /// Make [profile] the current [Profile] in use.
  ///
  /// Throws [NoSuchProfileException] if not found.
  void makeProfileCurrent(Profile profile);

  /// Validate the user name
  ///
  /// Throws [FormatException] if [name] violates requirements.
  void validateUserName(String name) {
    if (name.length < 3 || name.length > 50) {
      throw const FormatException(
          "Name must be between 3 and 50 characters long");
    }

    if (!_isAlphanumeric(name)) {
      throw const FormatException(
          "Name must only contain alphanumeric characters");
    }

    if (exists(name)) {
      throw FormatException("The user $name already exists");
    }
  }

  bool _isAlphanumeric(String s) {
    return RegExp(r'^[a-zA-Z0-9- ]+$').hasMatch(s);
  }
}