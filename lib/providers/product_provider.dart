import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_api_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductApiService _api = ProductApiService();
  List<ProductModel> products = [];
  bool isLoading = false;
  String? error;

  Future<void> loadProducts() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      products = await _api.fetchProducts();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }
}