import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_abhushan/models/bill.dart';
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

  Future<Bill> addBill(Bill reqData) async {
    try {
      final res = await _api.post('billings', body: reqData.toJson());
      final bill = Bill.fromMap(res);
      Toastr.show('Bill created successfully');
      return bill;
    } catch (e) {
      rethrow;
    }
  }

  Future<Bill> updateBill(String id, Bill updatedBill) async {
    try {
      final res = await _api.put('billings/$id', body: updatedBill.toJson());
      final bill = Bill.fromMap(res);
      return bill;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> fetchBills(String? keyword, int page, int limit, {String? status, String? customerId}) async {
    try {
      page = _prevSearch == keyword ? page : 1;
      _prevSearch = keyword;
      final response = await _api.post(
        'billings/search',
        body: {
          if(keyword != null && keyword.trim().isNotEmpty) 'keyword': keyword,
          if(status != null && status.trim().isNotEmpty) 'billStatus': status,
          if(customerId != null && customerId.trim().isNotEmpty) 'userId': customerId,
          'page': page,
          'limit': limit,
        }
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> deleteBill(String id) async {
    try {
      await _api.delete('billings/$id');
      Toastr.show('Bill deleted successfully');
      return id;
    } catch (e) {
      rethrow;
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
