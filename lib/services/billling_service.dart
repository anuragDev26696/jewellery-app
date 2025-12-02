import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_abhushan/models/bill.dart';
import 'package:swarn_abhushan/providers/billing_provider.dart';
import 'package:swarn_abhushan/services/loader_service.dart';
import 'package:swarn_abhushan/utils/api.dart';
import 'package:swarn_abhushan/utils/toastr.dart';

class BillingService {
  final Ref _ref;
  String? _prevSearch;
  late LoaderService _loaderService;

  BillingService(this._ref){
    _loaderService = _ref.read(loaderServiceProvider);
  }
  
  Api get _api => _ref.read(apiProvider);
  BillingNotifier get _billingNotifier => _ref.read(billingNotifierProvider.notifier);

  Future<Bill> addBill(Bill reqData) async {
    _loaderService.show();
    try {
      final res = await _api.post('billings', body: reqData.toJson());
      final bill = Bill.fromMap(res);
      _billingNotifier.addBill(bill);
      Toastr.show('Bill created successfully');
      return bill;
    } catch (e) {
      rethrow;
    } finally {
      _loaderService.hide();
    }
  }

  Future<Bill> updateBill(String id, Bill updatedBill) async {
    _loaderService.show();
    try {
      final res = await _api.put('billings/$id', body: updatedBill.toJson());
      final bill = Bill.fromMap(res);
      _billingNotifier.updateBill(bill);
      return bill;
    } catch (e) {
      rethrow;
    } finally {
      _loaderService.hide();
    }
  }

  Future<List<Bill>> fetchBills(String? keyword, int page, int limit, {String? status}) async {
    _loaderService.show();
    try {
      page = _prevSearch == keyword ? page : 1;
      _prevSearch = keyword;
      final response = await _api.post(
        'billings/search',
        body: {
          if(keyword != null && keyword.trim().isNotEmpty) 'keyword': keyword,
          if(status != null && status.trim().isNotEmpty) 'billStatus': status,
          'page': page,
          'limit': limit,
        }
      );
      final List data = response['data'] ?? [];
      final bills = data.map((e) => Bill.fromMap(e)).toList();
      await _billingNotifier.loadBills(
        bills: bills,
        total: response['total'] ?? bills.length,
        page: response['page'] ?? 1,
        limit: response['limit'] ?? limit,
        isLastPage: response['isLastPage'] ?? false,
        isPreviousPage: response['isPreviousPage'] ?? false,
        append: page > 1,
      );
      return bills;
    } catch (e) {
      rethrow;
    } finally {
      _loaderService.hide();
    }
  }

  Future<void> deleteBill(String id) async {
    _loaderService.show();
    try {
      await _api.delete('billings/$id');
      _billingNotifier.deleteBill(id);
      Toastr.show('Bill deleted successfully');
    } catch (e) {
      rethrow;
    } finally {
      _loaderService.hide();
    }
  }

  Future<Uint8List> downloadInvoicePdf(String billId) async {
    _loaderService.show();
    try {
      return await _api.getPdf('billings/$billId/invoice');
    } catch (e) {
      rethrow;
    } finally {
      _loaderService.hide();
    }
  }
}
