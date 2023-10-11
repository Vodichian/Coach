class Profile {
  String id;
  String name;
  DateTime birthday;
  Gender gender;

  Profile(this.id, this.name, this.birthday, this.gender);

  Profile.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        birthday = DateTime.parse(json['date']),
        gender = Gender.values.byName(json['gender']);

  static Map<String, dynamic> toJson(Profile profile) => {
        'id': profile.id,
        'name': profile.name,
        'date': profile.birthday.toString(),
        'gender': profile.gender.name,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          birthday == other.birthday &&
          gender == other.gender;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ birthday.hashCode ^ gender.hashCode;

  @override
  String toString() {
    return 'Profile{id: $id, name: $name, birthday: $birthday, gender: $gender}';
  }
}

enum Gender { male, female }
