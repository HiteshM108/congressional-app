class UserModel {

  final String uid;
  final String? name;
  final int age;
  final int weight;
  final int height;

  UserModel getUserData() {
    return this;
  }

  UserModel({ required this.uid, required this.name, required this.age, required this.height, required this.weight});
}