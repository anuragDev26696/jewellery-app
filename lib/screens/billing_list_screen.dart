import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_abhushan/providers/billing_provider.dart';
import 'package:swarn_abhushan/screens/new_bill_screen.dart';
import 'package:swarn_abhushan/utils/bill_item.dart';

class BillListScreen extends ConsumerStatefulWidget {
  const BillListScreen({super.key});

  @override
  ConsumerState<BillListScreen> createState() => _BillListScreenState();
}

class _BillListScreenState extends ConsumerState<BillListScreen> {
  final ScrollController _scrollController = ScrollController();
  // final TextEditingController _searchCtrl = TextEditingController();
  String? _keyword;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitial();
    });

    _scrollController.addListener(() {
      final state = ref.read(billingNotifierProvider);

      if (!_scrollController.position.outOfRange &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100) {
        if (!state.isLastPage) {
          _loadMore();
        }
      }
    });
  }

  Future<void> _fetchInitial() async {
    await ref.read(billingNotifierProvider.notifier).fetchBills(null, 1, 20);
  }

  Future<void> _loadMore() async {
    final st = ref.read(billingNotifierProvider);
    await ref.read(billingNotifierProvider.notifier).fetchBills(_keyword, st.page + 1, st.limit);
  }

  Future<void> _refresh() async {
    await ref.read(billingNotifierProvider.notifier).fetchBills(_keyword, 1, 20);
  }

  // void _onSearch(String value) async {
  //   _keyword = value.trim();
  //   final service = ref.read(billingServiceProvider);
  //   await service.fetchBills(_keyword, 1, 20);
  // }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(billingNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bills'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              _statusFilter = v;
              final service = ref.read(billingServiceProvider);
              await service.fetchBills(_keyword, 1, 20, status: _statusFilter);
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: '', child: Text('All')),
              PopupMenuItem(value: 'Pending', child: Text('Pending')),
              PopupMenuItem(value: 'Paid', child: Text('Paid')),
              PopupMenuItem(value: 'Partial Paid', child: Text('Partial Paid')),
            ],
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if(_statusFilter != null && _statusFilter!.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // _buildSearchBar(),

            // ░░░░░░ LIST WITH REFRESH ░░░░░░
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(bottom: 80),
                  itemCount: state.bills.length + (state.isLastPage ? 0 : 1),
                  itemBuilder: (context, index) {
                    if (index < state.bills.length) {
                      final bill = state.bills[index];
                      return Column(
                        children: [
                          if(index > 0) Divider(height: 1,),
                          BillItem(bill: bill, status: bill.paymentStatus),
                        ],
                      );
                    }

                    // ░░░░ LOADING INDICATOR FOR "LOAD MORE" ░░░░
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // ░░░░░░ STICKY BOTTOM BUTTON ░░░░░░
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        // decoration: const BoxDecoration(
        //   color: Colors.white,
        //   border: Border(top: BorderSide(color: Colors.black12)),
        // ),
        child: SafeArea(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewBillScreen())),
              child: const Text("Create New Bill"),
            ),
          ),
        ),
      ),
    );
  }

  // ░░░░ SEARCH BAR WIDGET ░░░░
  // Widget _buildSearchBar() {
  //   return Container(
  //     padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
  //     child: TextField(
  //       controller: _searchCtrl,
  //       onChanged: _onSearch,
  //       decoration: InputDecoration(
  //         hintText: "Search by name, phone, item...",
  //         prefixIcon: const Icon(Icons.search),
  //         contentPadding: const EdgeInsets.symmetric(vertical: 0),
  //       ),
  //     ),
  //   );
  // }
}
