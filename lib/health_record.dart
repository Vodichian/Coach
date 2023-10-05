/// "Measurement Date","Timezone","Weight(kg)","Body Fat(%)","Visceral Fat","Resting Metabolism(kcal)","Skeletal Muscle(%)","Skeletal Muscle（ARMS）(%)","Skeletal Muscle（TRUNK）(%)","Skeletal Muscle（LEGS）(%)","Subcutaneous fat(%)","Subcutaneous fat（ARMS）(%)","Subcutaneous fat（TRUNK）(%)","Subcutaneous fat（LEGS）(%)","BMI","Body Age(years old)","Device"
/// "2023/07/01 12:08","Asia/Ho_Chi_Minh","81.00","28.9","21.0","1736","28.3","33.6","20.7","45.7","20.9","25.9","19.5","26.4","31.6","62","HBF-702T"

class HealthRecord {
  static const String unknownDevice = "Unknown Device";
  DateTime date;
  double weight;
  double visceralFat = 0;
  double bodyFat = 0;
  double restingMetabolism = 0;
  double skeletalMuscle = 0;
  double skeletalMuscleArms = 0;
  double skeletalMuscleTrunk = 0;
  double skeletalMuscleLegs = 0;
  double subcutaneousFat = 0;
  double subcutaneousFatArms = 0;
  double subcutaneousFatTrunk = 0;
  double subcutaneousFatLegs = 0;
  double bmi = 0;
  double bodyAge = 0;
  String device = unknownDevice;

  HealthRecord(this.date, this.weight);
}