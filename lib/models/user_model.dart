class UserModel {
  String id;
  String name;

  factory UserModel.fromMap(data) {
    return UserModel(id: data['id'], name: data['name']);
  }

  UserModel({required this.id, required this.name});
}
