import 'dart:io';

import 'package:coach/database/database.dart';
import 'package:coach/database/health_record.dart';
import 'package:coach/database/local_database.dart';
import 'package:coach/database/profile.dart';
import 'package:coach/import.dart';
import 'package:test/test.dart';

// TODO: 10/7/2023 This whole test needs to be refactored to include Database changes
void main() {
  test('Import data from CSV file', () {
    File dataFile = File('test\\resources\\BodyComposition_202307-202309.csv');

    List<String> lines = dataFile.readAsLinesSync();
    Directory tmpDirectory = Directory.systemTemp.createTempSync();
    Database database = LocalDatabase(tmpDirectory);
    (database as LocalDatabase).clear();
    Profile profile = database.makeProfile("test");
    List<HealthRecord> data = Importer(database).loadFile(dataFile, profile);

    expect(data.length, equals(lines.length - 1)); // because header is stripped

    for (var element in data) {
      expect(element.date, isNotNull);
      expect(element.weight, greaterThan(0));
      expect(element.bodyFat, isNonZero);
      expect(element.visceralFat, isNonZero);
      expect(element.restingMetabolism, isNonZero);
      expect(element.skeletalMuscle, isNonZero);
      expect(element.skeletalMuscleArms, isNonZero);
      expect(element.skeletalMuscleTrunk, isNonZero);
      expect(element.skeletalMuscleLegs, isNonZero);
      expect(element.subcutaneousFat, isNonZero);
      expect(element.subcutaneousFatArms, isNonZero);
      expect(element.subcutaneousFatTrunk, isNonZero);
      expect(element.subcutaneousFatLegs, isNonZero);
      expect(element.bmi, isNonZero);
      expect(element.bodyAge, isNonZero);
      expect(element.device, isNot(HealthRecord.unknownDevice));
    }
  });
}
