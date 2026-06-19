class CommentModel {
  final String id;
  final String content;
  final String userName;
  final String? userAvatar;
  final String? userRole;
  final String userId;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.content,
    required this.userName,
    this.userAvatar,
    this.userRole,
    required this.userId,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? json['User'];
    return CommentModel(
      id: json['id'].toString(),
      content: json['content'] ?? '',
      userName: userData?['name'] ?? 'User',
      userAvatar: userData?['avatar'],
      userRole: userData?['role'],
      userId: json['userId']?.toString() ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}
