import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';

const limit = 10;
int totalProducts = 0;
int totalPages = 1;

class ProductRepository {
  final http.Client client;

  ProductRepository(this.client);

  Future<List<Product>> fetchProducts(int page) async {
    try {
      int skip = (page - 1) * limit;
      final response = await client.get(
          Uri.parse('https://dummyjson.com/products?limit=$limit&skip=$skip'));
      if (response.statusCode == 200) {
        final productList = productListFromJson(response.body);
        // if (page == 4) {
        //   totalProducts = 140;
        // } else {
        //   totalProducts = productList.total!;
        // }
        totalProducts = productList.total!;
        totalPages = (totalProducts / limit).ceil();
        return productList.products!;
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Failed to load products');
    }
  }
 

  Future<Product> fetchProduct(int id) async {
    try {
      final response =
          await client.get(Uri.parse('https://dummyjson.com/products/$id'));
      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load product');
      }
    } catch (e) {
      throw Exception('Failed to load product');
    }
  }
   Future<List<Product>> fetchInfinteProducts(int page) async {
    try {
      int skip = (page - 1) * limit;
      final response = await client.get(
          Uri.parse('https://dummyjson.com/products?limit=$limit&skip=$skip'));
      if (response.statusCode == 200) {
        final productList = productListFromJson(response.body);
     
 
        return productList.products!;
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Failed to load products');
    }
  }
}

final httpProvider = Provider<http.Client>((ref) {
  return http.Client();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.read(httpProvider));
});
