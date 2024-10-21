class UserModel {

  final String uid;
  final String? name;
  final String gender;
  final String activityLevel;
  final int age;
  final int weight;
  final int height;

  UserModel({ required this.uid, required this.name, required this.age, required this.height, required this.weight, required this.gender, required this.activityLevel });
}