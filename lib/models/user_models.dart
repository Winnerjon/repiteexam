class User {
  String? id;
  late String name;
  late String relationship;
  late String phoneNumber;

  User(
      {this.id,
        required this.name,
        required this.relationship,
        required this.phoneNumber});

  User.fromJson(Map<String,dynamic> json) {
    id = json["id"];
    name = json["name"];
    relationship = json["relationship"];
    phoneNumber = json['phoneNumber'];
  }

  Map<String,dynamic> toJson() => {
    "id" : id,
    "name" : name,
    "relationship" : relationship,
    "phoneNumber" : phoneNumber,
  };
}