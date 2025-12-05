import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_abhushan/models/item.dart';
import 'package:swarn_abhushan/providers/templates_provider.dart';
import 'package:swarn_abhushan/screens/billing_list_screen.dart';
import 'package:swarn_abhushan/screens/customer_ledger_screen.dart';
import 'package:swarn_abhushan/screens/templates_screen.dart';
import 'package:swarn_abhushan/utils/banner_carousel.dart';
import 'package:swarn_abhushan/utils/bill_item.dart';
import 'new_bill_screen.dart';
import '../providers/billing_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();
  final String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final notifier = ref.read(templateNotifierProvider.notifier);
      final billNotifier = ref.read(billingNotifierProvider.notifier);
      await notifier.searchItems(null);
      await billNotifier.fetchBills(null, 1, 5);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final billProvider = ref.watch(billingNotifierProvider);
    final billNotifier = ref.read(billingNotifierProvider.notifier);
    final filtered = _searchQuery.trim().isEmpty ? billProvider.bills : billNotifier.searchBills(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Swarn Abhushan'),
        leading: Padding(padding: EdgeInsets.only(left: 16.0), child: Image.asset('assets/logos/swarn_aabhushan.png', width: 30, height: 30, semanticLabel: 'Swarn Abhushan', fit: BoxFit.contain,),),
        // leadingWidth: 50,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Templates',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TemplatesScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            tooltip: 'Customer Ledger',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerLedgerScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  BannerCarousel(banners: [
                    BannerItem(imagePath: "assets/images/jewellery_1.jpg", tagline: 'Festive Offer — Up to 25% Off'),
                    BannerItem(imagePath: "assets/images/jewellery_2.jpg", tagline: 'New Diamond Collection'),
                    BannerItem(imagePath: "assets/images/jewellery_3.jpg", tagline: 'Elegant Silver Range'),
                    BannerItem(imagePath: "assets/images/jewellery_4.jpg", tagline: 'Gold Purity You Can Trust'),
                  ]),
                  const SizedBox(height: 12),
                  _quickTemplateSection(context),
                  if(filtered.isNotEmpty)
                    ...[
                      const SizedBox(height: 16),
                      _sectionHeader('Recent Bills', (){
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const BillListScreen()));
                      }),
                      // _buildSearchBar(Theme.of(context)),
                      const SizedBox(height: 5),
                    ],
                ],
              ),
            ),
            SliverList.separated(
              itemBuilder: (ctx, i) => BillItem(bill: filtered[i], status: filtered[i].paymentStatus),
              separatorBuilder: (_, __) => const Divider(height: 1, thickness: 1, color: Color.fromARGB(255, 45, 45, 45),),
              itemCount: filtered.length,
            ),
            SliverToBoxAdapter(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewBillScreen())),
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('New Bill'),
      ),
    );
  }

  // Widget _buildSearchBar(ThemeData theme) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8.0),
  //     child: TextField(
  //       controller: _searchCtrl,
  //       decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Search customer / phone / item'),
  //       onChanged: (v) {
  //         setState(() {
  //           _searchQuery = v;
  //         });
  //       },
  //     ),
  //   );
  // }

  Widget _sectionHeader(String title, void Function()? onViewAllPressed) {
    return Row(
      children: [
        const SizedBox(width: 12,),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
        ),
        const Spacer(),
        TextButton(
          onPressed: onViewAllPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("View All"),
              const SizedBox(width: 4), 
              Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ],
    );
  }

  // Widget _quickTemplates(List<Map<String, dynamic>> items) {
  //   return SizedBox(
  //     height: 100,
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal,
  //       itemCount: items.length,
  //       itemBuilder: (context, index) {
  //         final item = items[index];
  //         return Container(
  //           width: 100,
  //           margin: EdgeInsets.only(right: 12, left: index>0 ? 0 : 12),
  //           decoration: BoxDecoration(
  //             color: const Color(0xFF1C1C1C),
  //             borderRadius: BorderRadius.circular(12),
  //             border: Border.all(color: Colors.white10),
  //           ),
  //           child: InkWell(
  //             borderRadius: BorderRadius.circular(12),
  //             onTap: () {},
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Icon(item["icon"], color: Colors.amberAccent, size: 36),
  //                 const SizedBox(height: 8),
  //                 Text(item["name"],
  //                     style: const TextStyle(color: Colors.white70, fontSize: 13)),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget _quickTemplateSection(BuildContext context) {
    final templates = ref.watch(templateNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12.0,
      children: [
        _sectionHeader('Quick Add Jewellery', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const TemplatesScreen()));
        }),
        SizedBox(
          height: 200, // enough to show 2 rows
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              direction: Axis.vertical, // key: vertical flow for 2 rows
              children: templates.items.map((t) {
                return Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.0),
                    splashColor: const Color(0xFFFFC857).withValues(alpha: 0.2),
                    highlightColor: Colors.white10,
                    onTap: () {
                      _showTemplateBottomSheet(context, t);
                    },
                    child: Ink(
                      width: 100,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Color(0xFFFFC857).withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            t.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            t.type,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _showTemplateBottomSheet(BuildContext context, Item item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            // const SizedBox(height: 10),
            // Image.asset(item["image"]!, height: 120),
            const SizedBox(height: 10),
            const Text(
              "Do you want to add this item to your current bill?",
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC857),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text("Add to Bill"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
