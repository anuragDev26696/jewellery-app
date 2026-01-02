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
  final int currentYear = DateTime.now().year;
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

  void onclick(bool isNext) {
    if(activeDate.year == currentYear && isNext) return;
    setState(() {
      activeDate = isNext
          ? DateTime(activeDate.year + 1)
          : DateTime(activeDate.year - 1);
    });
    fetchChartData();
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
            Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Year: ${activeDate.year}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 260, child: buildChart()),
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
              child: buildNavigation(),
            ),
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
      spacing: 8.0,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: activeDate.year < 2021 ? null : () => onclick(false), 
          child: const Text('Previous'),
        ),
        ElevatedButton(
          onPressed: activeDate.year == currentYear ? null : () => onclick(true), 
          child: const Text('Next'),
        ),
      ],
    );
  }
}