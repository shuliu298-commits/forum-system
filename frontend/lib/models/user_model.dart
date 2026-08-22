/// 用户模型(对应后端 UserResponse)。
class UserModel {
  final int id;
  final String username;
  final String? createTime;

  const UserModel({
    required this.id,
    required this.username,
    this.createTime,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        username: json['username'] as String,
        createTime: json['createTime'] as String?,
      );
}
