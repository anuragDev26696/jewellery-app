import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_abhushan/models/bill.dart';
import 'package:swarn_abhushan/providers/billing_provider.dart';
import 'package:swarn_abhushan/utils/chart.dart';

class BillingChartScreen extends ConsumerStatefulWidget {
  const BillingChartScreen({super.key});

  @override
  ConsumerState<BillingChartScreen> createState() => _BillingChartScreenState();
}
class _BillingChartScreenState extends ConsumerState<BillingChartScreen> {
  bool isLoading = false;
  DateTime activeDate = DateTime.now();
  List<BillingChartModel> chartData = [];
  
  @override
  void initState() {
    super.initState();
    fetchChartData();
  }

  Future<void> fetchChartData() async {
    setState(() => isLoading = true);

    try {
      final data = await ref.read(billingServiceProvider).fetchChartData(activeDate.year);
      setState(() => chartData = data);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing Chart'),
      ),
      body: SafeArea(
        child: Column(
          spacing: 12.0,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
              child: buildNavigation(),
            ),
            SizedBox(height: 260, child: buildChart()),
          ],
        ),
      ),
    );
  }

  Widget buildChart() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chartData.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Chart(chartData: chartData),
    );
  }

  Widget buildNavigation() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => setState(() {
            activeDate = DateTime(activeDate.year - 1);
          }), 
          child: const Text('Previous Year'),
        ),
        ElevatedButton(
          onPressed: () => setState(() {
            activeDate = DateTime(activeDate.year + 1);
          }), 
          child: const Text('Next Year'),
        ),
      ],
    );
  }
}