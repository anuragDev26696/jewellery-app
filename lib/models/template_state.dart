import 'package:swarn_abhushan/models/item.dart';

class TemplateState {
  final List<Item> items;
  final bool isLoading;
  final bool isAdding;
  final bool isUpdating;
  final bool isDeleting;
  final int page;
  final int limit;
  final int total;
  final bool hasNextPage;
  final String? error;

  const TemplateState({
    this.items = const [],
    this.isLoading = false,
    this.isAdding = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.page = 1,
    this.limit = 10,
    this.total = 0,
    this.hasNextPage = false,
    this.error,
  });

  TemplateState copyWith({
    List<Item>? items,
    bool? isLoading,
    bool? isAdding,
    bool? isUpdating,
    bool? isDeleting,
    int? page,
    int? limit,
    int? total,
    bool? hasNextPage,
    String? error,
  }) {
    return TemplateState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isAdding: isAdding ?? this.isAdding,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      error: error,
    );
  }

  factory TemplateState.initial() => const TemplateState();
}