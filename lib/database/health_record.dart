/// "Measurement Date","Timezone","Weight(kg)","Body Fat(%)","Visceral Fat","Resting Metabolism(kcal)","Skeletal Muscle(%)","Skeletal Muscle（ARMS）(%)","Skeletal Muscle（TRUNK）(%)","Skeletal Muscle（LEGS）(%)","Subcutaneous fat(%)","Subcutaneous fat（ARMS）(%)","Subcutaneous fat（TRUNK）(%)","Subcutaneous fat（LEGS）(%)","BMI","Body Age(years old)","Device"
/// "2023/07/01 12:08","Asia/Ho_Chi_Minh","81.00","28.9","21.0","1736","28.3","33.6","20.7","45.7","20.9","25.9","19.5","26.4","31.6","62","HBF-702T"

class HealthRecord {
  static const String unknownDevice = "Unknown Device";
  String id;
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

  HealthRecord(this.id, this.date, this.weight);

  HealthRecord.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        date = DateTime.parse(json['date']),
        weight = json['weight'],
        visceralFat = json['visceralFat'],
        bodyFat = json['bodyFat'],
        restingMetabolism = json['restingMetabolism'],
        skeletalMuscle = json['skeletalMuscle'],
        skeletalMuscleArms = json['skeletalMuscleArms'],
        skeletalMuscleTrunk = json['skeletalMuscleTrunk'],
        skeletalMuscleLegs = json['skeletalMuscleLegs'],
        subcutaneousFat = json['subcutaneousFat'],
        subcutaneousFatArms = json['subcutaneousFatArms'],
        subcutaneousFatTrunk = json['subcutaneousFatTrunk'],
        subcutaneousFatLegs = json['subcutaneousFatLegs'],
        bmi = json['bmi'],
        bodyAge = json['bodyAge'],
        device = json['device'];

  static Map<String, dynamic> toJson(HealthRecord record) => {
        'id': record.id,
        'date': record.date.toString(),
        'weight': record.weight,
        'visceralFat': record.visceralFat,
        'bodyFat': record.bodyFat,
        'restingMetabolism': record.restingMetabolism,
        'skeletalMuscle': record.skeletalMuscle,
        'skeletalMuscleArms': record.skeletalMuscleArms,
        'skeletalMuscleTrunk': record.skeletalMuscleTrunk,
        'skeletalMuscleLegs': record.skeletalMuscleLegs,
        'subcutaneousFat': record.subcutaneousFat,
        'subcutaneousFatArms': record.subcutaneousFatArms,
        'subcutaneousFatTrunk': record.subcutaneousFatTrunk,
        'subcutaneousFatLegs': record.subcutaneousFatLegs,
        'bmi': record.bmi,
        'bodyAge': record.bodyAge,
        'device': record.device,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          date == other.date &&
          weight == other.weight &&
          visceralFat == other.visceralFat &&
          bodyFat == other.bodyFat &&
          restingMetabolism == other.restingMetabolism &&
          skeletalMuscle == other.skeletalMuscle &&
          skeletalMuscleArms == other.skeletalMuscleArms &&
          skeletalMuscleTrunk == other.skeletalMuscleTrunk &&
          skeletalMuscleLegs == other.skeletalMuscleLegs &&
          subcutaneousFat == other.subcutaneousFat &&
          subcutaneousFatArms == other.subcutaneousFatArms &&
          subcutaneousFatTrunk == other.subcutaneousFatTrunk &&
          subcutaneousFatLegs == other.subcutaneousFatLegs &&
          bmi == other.bmi &&
          bodyAge == other.bodyAge &&
          device == other.device;

  @override
  int get hashCode =>
      id.hashCode ^
      date.hashCode ^
      weight.hashCode ^
      visceralFat.hashCode ^
      bodyFat.hashCode ^
      restingMetabolism.hashCode ^
      skeletalMuscle.hashCode ^
      skeletalMuscleArms.hashCode ^
      skeletalMuscleTrunk.hashCode ^
      skeletalMuscleLegs.hashCode ^
      subcutaneousFat.hashCode ^
      subcutaneousFatArms.hashCode ^
      subcutaneousFatTrunk.hashCode ^
      subcutaneousFatLegs.hashCode ^
      bmi.hashCode ^
      bodyAge.hashCode ^
      device.hashCode;

  @override
  String toString() {
    return 'HealthRecord{id: $id, date: $date, weight: $weight, visceralFat: $visceralFat, bodyFat: $bodyFat, restingMetabolism: $restingMetabolism, skeletalMuscle: $skeletalMuscle, skeletalMuscleArms: $skeletalMuscleArms, skeletalMuscleTrunk: $skeletalMuscleTrunk, skeletalMuscleLegs: $skeletalMuscleLegs, subcutaneousFat: $subcutaneousFat, subcutaneousFatArms: $subcutaneousFatArms, subcutaneousFatTrunk: $subcutaneousFatTrunk, subcutaneousFatLegs: $subcutaneousFatLegs, bmi: $bmi, bodyAge: $bodyAge, device: $device}';
  }
}