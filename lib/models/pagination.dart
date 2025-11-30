import 'dart:convert';

class PaginationRes<T> {
  final List<T> data;
  final bool isLastPage;
  final bool isPreviousPage;
  final int total;
  final int page;
  final int limit;

  PaginationRes({
    required this.data,
    required this.isLastPage,
    required this.isPreviousPage,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory PaginationRes.fromMap(
    Map<String, dynamic> map,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    final list = (map['data'] as List<dynamic>? ?? [])
        .map((item) => fromMap(item as Map<String, dynamic>))
        .toList();

    return PaginationRes(
      data: list,
      total: map['total'] ?? list.length,
      isLastPage: map['isLastPage'] ?? false,
      isPreviousPage: map['isPreviousPage'] ?? false,
      page: map['page'] ?? 1,
      limit: map['limit'] ?? 10,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "data": data,
      "total": total,
      "page": page,
      "limit": limit,
      "isLastPage": isLastPage,
      "isPreviousPage": isPreviousPage
    };
  }

  String toJson() => json.encode(toMap());
  factory PaginationRes.fromJson(String source, T Function(Map<String, dynamic>) fromMap) => 
      PaginationRes.fromMap(json.decode(source) as Map<String, dynamic>, fromMap);
}