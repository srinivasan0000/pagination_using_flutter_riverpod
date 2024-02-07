import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:pagination_using_flutter_riverpod/repositories/product_repository.dart';

import '../../models/product.dart';
import '../product_detail/product_detail_page.dart';

final getProductsProvider =
    FutureProvider.family.autoDispose<List<Product>, int>((ref, page) async {
  Timer? timer;
  final keepAliveLink = ref.keepAlive();
  ref.onCancel(() {
    timer = Timer(const Duration(seconds: 10), () {
      keepAliveLink.close();
    });
  });
  ref.onDispose(() {
    timer?.cancel();
  });
  ref.onResume(() {
    timer?.cancel();
  });

  return ref.watch(productRepositoryProvider).fetchProducts(page);
});

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  int page = 1;
  @override
  Widget build(BuildContext context) {
    final productList = ref.watch(getProductsProvider(page));
    return Scaffold(
        appBar: AppBar(
          title: const Text('Number Pagination'),
        ),
        body: productList.when(
          data: (products) {
            return ListView.separated(
                itemBuilder: (context, index) {
                  final product = products[index];
                  return InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailPage(id: product.id!))),
                    child: ListTile(
                      title: Row(
                        children: [
                          CircleAvatar(
                              backgroundImage: Image.network(
                            products[index].thumbnail!,
                            fit: BoxFit.cover,
                          ).image),
                          const SizedBox(width: 15),
                          Text(product.title!),
                        ],
                      ),
                      subtitle: Text(product.description!),
                      trailing: Text('\$${product.price}',
                          style: const TextStyle(fontSize: 18)),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
                itemCount: products.length);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error: $error'),
        ),
        bottomNavigationBar: totalProducts == 0 && totalPages == 1
            ? SizedBox()
            : SafeArea(
                child: Card(
                  child: NumberPaginator(
                    numberPages: totalPages,
                    onPageChange: (index) {
                      page = index + 1;
                      setState(() {});
                    },
                  ),
                ),
              ));
  }
}
