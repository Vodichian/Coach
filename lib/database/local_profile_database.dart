import 'dart:convert';
import 'dart:io';

import 'package:coach/database/no_such_profile_exception.dart';
import 'package:coach/database/profile.dart';
import 'package:coach/database/profile_database.dart';
import 'package:logger/logger.dart%20';
import 'package:uuid/uuid.dart';

class LocalProfileDatabase extends ProfileDatabase {
  var logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  final List<Profile> _profiles = [];
  final Uuid uuid = const Uuid();
  final File _profilesFile;

  LocalProfileDatabase(this._profilesFile) {
    load();
  }

  void load() {
    _profiles.clear();
    if (_profilesFile.existsSync()) {
      final contents = _profilesFile.readAsStringSync();
      if (contents.isEmpty) return;

      List decodedList = jsonDecode(
        contents,
        reviver: (key, value) {
          if (value is Map<String, dynamic>) {
            return Profile.fromJson(value);
          }
          return value;
        },
      );

      for (var element in decodedList) {
        _profiles.add(element);
      }
    }
    notifyListeners();
  }

  @override
  Profile add(String name, DateTime birthday, Gender gender) {
    validateUserName(name);

    Profile profile = Profile(uuid.v1(), name, birthday, gender);
    _profiles.add(profile);
    _persist();
    return profile;
  }

  @override
  Profile currentProfile() {
    if (_profiles.isEmpty) {
      throw NoSuchProfileException("No profiles exist");
    }
    return _profiles.first;
  }

  @override
  void makeProfileCurrent(Profile profile) {
    /// A profile is made current by moving it to the top of the _profiles data structure
    int index = _profiles.indexOf(profile);
    if (index < 0) {
      throw NoSuchProfileException(
          "${profile.name}'s profile does not exist in the database");
    } else if (index == 0) {
      return; // profile is already first in list
    } else {
      _profiles.removeAt(index);
      _profiles.insert(0, profile);
      _persist();
    }
  }

  @override
  bool exists(String name) {
    for (var profile in _profiles) {
      if (profile.name == name) {
        return true;
      }
    }
    return false;
  }

  @override
  Profile findById(String id) {
    return _profiles.singleWhere((element) => element.id == id,
        orElse: () =>
            throw NoSuchProfileException("No profile exists with ID: $id"));
  }

  @override
  Profile findByName(String name) {
    return _profiles.singleWhere((element) => element.name == name,
        orElse: () =>
            throw NoSuchProfileException("No profile exists with name: $name"));
  }

  @override
  List<Profile> profiles() {
    return _profiles.toList();
  }

  @override
  void remove(Profile profile) {
    bool success = _profiles.remove(profile);
    if (success) {
      _persist();
    } else {
      throw NoSuchProfileException(
          "Could not remove $profile because it does not exist");
    }
  }

  @override
  void update(Profile profile) {
    Profile persisted = findById(profile.id);
    persisted.gender = profile.gender;
    persisted.name = profile.name;
    persisted.birthday = profile.birthday;
    _persist();
  }

  void _persist() async {
    String jsonString = json.encode(
      _profiles,
      toEncodable: (object) => Profile.toJson(object),
    );

    _profilesFile.writeAsStringSync(jsonString);
    notifyListeners();
  }

  /// Wipes all [Profile] objects from the database.
  ///
  /// Intended for testing, use with caution.
  void clear() {
    _profiles.clear();
    _persist();
  }
}
