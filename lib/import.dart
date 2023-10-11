import 'dart:io' as io;

import 'package:coach/database/database.dart';
import 'package:coach/database/health_record.dart';
import 'package:logger/logger.dart';

import 'database/profile.dart';

var logger = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

class Importer {
  final Database database;

  Importer(this.database);

  List<HealthRecord> loadFile(io.File file, Profile profile) {
    if (file.existsSync()) {
      return _processData(file.readAsLinesSync(), profile);
    } else {
      throw Exception("File did not exist");
    }
  }

  /// Test method, used to learn Dart
  List<HealthRecord> _processData(List<String> list, profile) {
    var header = list.removeAt(0);

    var fields = header.split(',');
    if (fields.length == 17 && fields[16] == "\"Device\"") {
      logger.d("This is an Omron device");
      return _importFromHBF702T(list, profile);
    } else {
      throw const FormatException("Unknown data format");
    }
  }

  /// Import from HBF-702T.
  /// This expects the data list **only**, with the header stripped off.
  List<HealthRecord> _importFromHBF702T(
      List<String> dataList, Profile profile) {
    // verify is for the HBF-702T
    if (dataList.isEmpty) {
      throw const FormatException("Import data was empty");
    }

    var healthDataList = <HealthRecord>[];

    if (!dataList.first.contains("HBF-702T")) {
      throw const FormatException("Not a valid HBF-702T export file");
    }

    for (var element in dataList) {
      healthDataList.add(_convertHBF702T(element, profile));
    }

    return healthDataList;
  }

  HealthRecord _convertHBF702T(String dataLine, Profile profile) {
    var elements = dataLine.split(",");
    var date = _extractDate(elements[0]);
    var weight = _extractDouble(elements[2]);
    var bodyFat = _extractDouble(elements[3]);
    var visceralFat = _extractDouble(elements[4]);
    var restingMetabolism = _extractDouble(elements[5]);
    var skeletalMuscle = _extractDouble(elements[6]);
    var skeletalMuscleArms = _extractDouble(elements[7]);
    var skeletalMuscleTrunk = _extractDouble(elements[8]);
    var skeletalMuscleLegs = _extractDouble(elements[9]);
    var subcutaneousFat = _extractDouble(elements[10]);
    var subcutaneousFatArms = _extractDouble(elements[11]);
    var subcutaneousFatTrunk = _extractDouble(elements[12]);
    var subcutaneousFatLegs = _extractDouble(elements[13]);
    var bmi = _extractDouble(elements[14]);
    var bodyAge = _extractDouble(elements[15]);
    var device = _stripQuotes(elements[16]);

    HealthRecord record = database.makeRecord(date, weight, profile);
    record.bodyFat = bodyFat;
    record.visceralFat = visceralFat;
    record.restingMetabolism = restingMetabolism;
    record.skeletalMuscle = skeletalMuscle;
    record.skeletalMuscleArms = skeletalMuscleArms;
    record.skeletalMuscleTrunk = skeletalMuscleTrunk;
    record.skeletalMuscleLegs = skeletalMuscleLegs;
    record.subcutaneousFat = subcutaneousFat;
    record.subcutaneousFatArms = subcutaneousFatArms;
    record.subcutaneousFatTrunk = subcutaneousFatTrunk;
    record.subcutaneousFatLegs = subcutaneousFatLegs;
    record.bmi = bmi;
    record.bodyAge = bodyAge;
    record.device = device;
    database.updateRecord(record, profile);

    return record;
  }

  DateTime _extractDate(String dateString) {
    return DateTime.parse(_stripQuotes(dateString).replaceAll("/", "-"));
  }

  /// remove " from beginning and end of the provided String
  String _stripQuotes(String value) {
    return value.substring(1, value.length - 1);
  }

  double _extractDouble(String element) {
    return double.parse(_stripQuotes(element));
  }
}
