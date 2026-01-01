import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_abhushan/providers/payment_provider.dart';
import 'package:swarn_abhushan/utils/constant.dart';

class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  ConsumerState<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentNotifierProvider.notifier).searchPayment();
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        final state = ref.read(paymentNotifierProvider);
        if (!state.isLastPage && !state.isLoading && state.isLastPage == false) {
          final page = state.page + 1;
          ref.read(paymentNotifierProvider.notifier).searchPayment(page: page);
        }
      }
    });
  }
  
  Future<void> onRefresh() async {
    await ref.read(paymentNotifierProvider.notifier).searchPayment(page: 1);
  }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
      ),
      body: state.items.isNotEmpty ? SafeArea(
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.only(bottom: 80),
            itemCount: state.total+(state.isLastPage ? 0 : 1),
            itemBuilder: (context, index) {
              final payment = state.items[index];
              if (index < state.items.length) {
                return Column(
                  children: [
                    if(index > 0) Divider(height: 1,),
                    ListTile(
                      title: Text(payment.customerName, overflow: TextOverflow.ellipsis,),
                      subtitle: Text('${CommonUtils.formatCurrency(payment.amount)} - ${payment.paymentMode}'),
                    ),
                  ],
                );
              }
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
      ) : Center(
        child: state.isLoading ? CircularProgressIndicator() : Text('Payment history details will be shown here.'),
      ),
    );
  }
}