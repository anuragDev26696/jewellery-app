import 'dart:convert';

class User {
  String? uuid;
  String name;
  String mobile;
  String? email;
  String? address;
  bool? isDeleted;

  User({
    this.uuid,
    required this.name,
    required this.mobile,
    this.email,
    this.address,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() => {
    'uuid': uuid,
    'name': name,
    'mobile': mobile,
    'email': email,
    'address': address,
    'isDeleted': isDeleted,
  };

  factory User.fromMap(Map<String, dynamic> map) => User(
    uuid: map['uuid'] ?? "",
    name: map['name'] ?? "",
    mobile: map['mobile'] ?? "",
    email: map['email'] ?? "",
    address: map['address'] ?? "",
    isDeleted: map['isDeleted'] ?? false,
  );

  String toJson() => json.encode(toMap());
  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}

class UserState {
  final List<User> users;
  final int total;
  final int page;
  final int limit;
  final bool isLastPage;
  final bool isPreviousPage;
  final bool isLoading;
  final bool isAdding;
  final bool isUpdating;
  final bool isDeleting;

  const UserState({
    this.users = const [],
    this.total = 0,
    this.page = 1,
    this.limit = 10,
    this.isLastPage = false,
    this.isPreviousPage = false,
    this.isLoading = false,
    this.isAdding = false,
    this.isUpdating = false,
    this.isDeleting = false,
  });

  UserState copyWith({
    List<User>? users,
    int? total,
    int? page,
    int? limit,
    bool? isLastPage,
    bool? isPreviousPage,
    bool? isLoading,
    bool? isAdding,
    bool? isUpdating,
    bool? isDeleting,
  }) {
    return UserState(
      users: users ?? this.users,
      total: total ?? this.total,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      isLastPage: isLastPage ?? this.isLastPage,
      isPreviousPage: isPreviousPage ?? this.isPreviousPage,
      isLoading: isLoading ?? false,
      isAdding: isAdding ?? this.isAdding,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}
