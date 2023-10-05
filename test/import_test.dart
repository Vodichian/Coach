import 'dart:io' as io;

import 'package:coach/health_record.dart';
import 'package:coach/import.dart';
import 'package:test/test.dart';

void main() {
  test('Import data from CSV file', () {
    // TODO: Move this file into a test assets directory
    io.File dataFile = io.File(
        'C:\\Users\\Rick\\Nextcloud\\BodyComposition_202307-202309.csv');

    List<String> lines = dataFile.readAsLinesSync();
    List<HealthRecord> data = Importer().loadFile(dataFile);

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
