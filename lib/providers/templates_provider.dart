import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:swarn_abhushan/models/template_state.dart';
import 'package:swarn_abhushan/services/items_service.dart';
import 'package:swarn_abhushan/services/loader_service.dart';
import 'package:swarn_abhushan/utils/toastr.dart';
import '../models/item.dart';

class TemplateNotifier extends StateNotifier<TemplateState> {
  final ItemService _service;
  final LoaderService _loader;

  TemplateNotifier(this._service, this._loader) : super(TemplateState.initial());

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasNextPage) return;
    state = state.copyWith(isLoading: true);
    try {
      final nextPage = state.page + 1;
      final result = await _service.fetchItems(null, nextPage, state.limit);
      final newItems = [...state.items, ...result['data']!] as List<Item>;
      state = state.copyWith(
        items: newItems,
        page: nextPage,
        total: result.total,
        hasNextPage: !result.isLastPage,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addTemplate(Item item) async {
    state = state.copyWith(isAdding: true, error: null);
    try {
      _loader.show();
      var response = await _service.createNew(item.toMap());
      final newItem = Item.fromMap(response);
      state = state.copyWith(items: [newItem, ...state.items], isAdding: false);
      Toastr.show('Item added successfully');
    } catch (e) {
      state = state.copyWith(isAdding: false, error: e.toString());
    } finally {
      _loader.hide();
    }
  }

  Future<void> updateItem(String uuid, Item updated) async {
    if(uuid.isEmpty) {
      Toastr.show('Invalid item id', success: false);
      return;
    }
    state = state.copyWith(isUpdating: true, error: null);
    try {
      _loader.show();
      final response = await _service.updateItem(uuid, updated.toMap());
      final updatedItem = Item.fromMap(response);
      final updatedList = state.items.map((t) => t.uuid == uuid ? updatedItem : t).toList();
      state = state.copyWith(items: updatedList, isUpdating: false);
      Toastr.show('Item Update successfully');
    } catch (e) {
      state = state.copyWith(isUpdating: false, error: e.toString());
    } finally {
      _loader.hide();
    }
  }

  Future<void> deleteItem(String id) async {
    if(id.isEmpty) {
      Toastr.show('Invalid item id', success: false);
      return;
    }
    state = state.copyWith(isUpdating: true, error: null);
    try {
      _loader.show();
      await _service.deleteItem(id);
      final updatedList = state.items.where((t) => t.uuid != id).toList();
      state = state.copyWith(items: updatedList, isUpdating: false);
      Toastr.show('Item deleted successfully');
    } catch (e) {
      state = state.copyWith(isUpdating: false, error: e.toString());
    } finally {
      _loader.hide();
    }
  }

  Future<void> searchItems(String? keyword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _service.fetchItems(keyword, 1, state.limit);
      
      final rawItemList = res['data'] as List<dynamic>?;
      final itemModels = rawItemList?.map((itemMap) => Item.fromMap(itemMap)).toList() ?? [];

      state = state.copyWith(
        items: itemModels, 
        total: res['total'] ?? 0,
        hasNextPage: !(res['isLastPage'] ?? true),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearAll() {
    state = const TemplateState();
  }
}


final templateServiceProvider = Provider<ItemService>((ref) {
  return ItemService();
});

final templateNotifierProvider = StateNotifierProvider<TemplateNotifier, TemplateState>((ref) {
  final service = ref.watch(templateServiceProvider);
  final loader = ref.watch(loaderServiceProvider);
  return TemplateNotifier(service, loader);
});
