import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_abhushan/utils/constant.dart';
import 'package:swarn_abhushan/utils/item_form_dialog.dart';
import 'package:swarn_abhushan/utils/toastr.dart';
import '../providers/templates_provider.dart';
import '../models/item.dart';

class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(templateNotifierProvider.notifier).searchItems(null);
    });
    _scrollController.addListener(() {
      FocusScope.of(context).unfocus();
      final state = ref.read(templateNotifierProvider);
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !state.isLoading && state.hasNextPage) {
        ref.read(templateNotifierProvider.notifier).loadMore();
      }
    });
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openAddDialog({Item? edit}) {
    showDialog<Item>(context: context, builder: (_) => ItemFormDialog(
      prefill: edit,
      title: edit == null ? 'Add Template' : 'Edit Template',
      confirmText: edit == null ? 'Add' : 'Save',
      onSubmit: (result) async {
        if (edit == null) {
          await ref.read(templateNotifierProvider.notifier).addTemplate(result);
        } else {
          await ref.read(templateNotifierProvider.notifier).updateItem(edit.uuid!, result);
        }
        if(!mounted) return;
        Navigator.pop(context);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(templateNotifierProvider);
    final notifier = ref.read(templateNotifierProvider.notifier);
    final gold = Theme.of(context).colorScheme.primary;
    final offWhite = Theme.of(context).colorScheme.onSurface;

    if (state.isLoading && state.items.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Item Templates'), actions: [
        // IconButton(icon: const Icon(Icons.delete_sweep), onPressed: () async {
        //   final confirmed = await showDialog<bool>(
        //     context: context,
        //     builder: (c) => AlertDialog(
        //       title: const Text('Clear all templates?'),
        //       actions: [
        //         TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        //         TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Clear')),
        //       ],
        //     ),
        //   );
        //   if (confirmed == true) {
        //     notifier.clearAll();
        //   }
        // }),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddDialog(),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: state.items.isEmpty
          ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2, size: 64, color: Colors.white54),
                const SizedBox(height: 12),
                const Text('No templates yet.', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _openAddDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Template'),
                ),
              ],
            )
          )
          : RefreshIndicator(
            onRefresh: () => notifier.searchItems(null),
            child: ListView.separated(
              itemCount: state.items.length + (state.isLoading && state.items.isNotEmpty ? 1 : 0),
              separatorBuilder: (_, __) => const Divider(height: 1,),
              itemBuilder: (ctx, i) {
                if (i == state.items.length && state.isLoading && state.items.isNotEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator(color: gold,)),
                  );
                }
                final t = state.items[i];
                return ListTile(
                  title: Text(t.name.isNotEmpty ? t.name : t.type, style: TextStyle(fontSize: 16.0),),
                  subtitle: Text('Wt:${t.weight}g • Rate: ${CommonUtils.formatCurrency(t.pricePerGram)}/g • Making: ${t.makingCharge}%', style: TextStyle(color: Colors.white54, fontSize: 12.0),),
                  trailing: Wrap(children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _openAddDialog(edit: t), color: offWhite.withValues(alpha: 0.8),),
                    IconButton(icon: const Icon(Icons.delete), onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Are you sure you want to delete?', textAlign: TextAlign.center,),
                          actionsAlignment: MainAxisAlignment.start,
                          actionsOverflowButtonSpacing: 12.0,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          icon: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade900.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete_forever_rounded,
                              size: 40,
                              color: Colors.red,
                            ),
                          ),
                          actions: [
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(c, false),
                                child: const Text('Cancel'),
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(c, true),
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty .resolveWith<Color?>((states) => Colors.red),
                                  // foregroundColor: WidgetStatePropertyAll(Colors.red),
                                ),
                                child: const Text('Delete'),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        if(t.uuid!.isEmpty && mounted) {
                          Toastr.show('Invalid template id', success: false);
                          return;
                        }
                        await notifier.deleteItem(t.uuid!);
                      }
                    },
                    color: Colors.red.shade400,
                    ),
                  ]),
                );
              },
            ),
          ),
      ),
    );
  }
}
