import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_abhushan/models/item.dart';
import 'package:swarn_abhushan/providers/templates_provider.dart';
import 'package:swarn_abhushan/screens/templates_screen.dart';
import 'package:swarn_abhushan/utils/constant.dart';

class BillItemHeader extends ConsumerWidget {
  final int itemCount;
  final VoidCallback onAddItem;
  final void Function(Item template)? onQuickAddFromTemplate;
  final String title;

  const BillItemHeader({
    super.key,
    required this.itemCount,
    required this.onAddItem,
    this.onQuickAddFromTemplate,
    this.title = "Items",
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final templates = ref.watch(templateNotifierProvider).items;

    return Row(
      children: [
        Text(
          '$title ($itemCount)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const Spacer(),

        // ADD ITEM BUTTON
        ElevatedButton.icon(
          onPressed: onAddItem,
          icon: const Icon(Icons.add),
          label: const Text('Add Item'),
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: Colors.black,
          ),
        ),

        const SizedBox(width: 8),

        // QUICK ADD BUTTON
        OutlinedButton.icon(
          onPressed: () => _showQuickAddBottomSheet(context, templates),
          icon: const Icon(Icons.flash_on),
          label: const Text('Quick Add'),
          style: OutlinedButton.styleFrom(
            foregroundColor: cs.primary,
            side: BorderSide(color: cs.primary),
          ),
        ),
      ],
    );
  }

  // ===========================
  // QUICK ADD BOTTOM SHEET
  // ===========================
  void _showQuickAddBottomSheet(
      BuildContext context, List<Item> templates) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      builder: (ctx) => SizedBox(
        height: 360,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Container(
                height: 4.0,
                width: 40.0,
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),

            ListTile(
              title: Text(
                'Templates',
                style: TextStyle(color: cs.onSurface),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                color: cs.primary,
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TemplatesScreen()));
                },
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: templates.isEmpty
                  ? Center(
                      child: Text(
                        'No templates. Add from Templates screen.',
                        style: TextStyle(color: cs.onSurface),
                      ),
                    )
                  : ListView.builder(
                      itemCount: templates.length,
                      itemBuilder: (c, idx) {
                        final t = templates[idx];

                        return ListTile(
                          title: Text(
                            t.name.isNotEmpty ? t.name : t.type,
                            style: TextStyle(color: cs.onSurface),
                          ),
                          subtitle: Text(
                            'Wt: ${t.weight}g • Rate: ${CommonUtils.formatCurrency(t.pricePerGram)} • Making: ${CommonUtils.formatCurrency(t.makingCharge)}',
                            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7)),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            color: cs.primary,
                            onPressed: () {
                              Navigator.pop(ctx);
                              onQuickAddFromTemplate?.call(t);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

