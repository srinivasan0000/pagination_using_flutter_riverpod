import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../models/product.dart';
import '../../repositories/product_repository.dart';
import '../product_detail/product_detail_page.dart';

class InfiniteProductsPage extends ConsumerStatefulWidget {
  const InfiniteProductsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _InfiniteProductsPageState();
}

class _InfiniteProductsPageState extends ConsumerState<InfiniteProductsPage> {
  final PagingController<int, Product> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchProducts(pageKey);
    });
  }

  Future<void> _fetchProducts(int pageKey) async {
    try {
      final newProducts = await ref
          .read(productRepositoryProvider)
          .fetchInfinteProducts(pageKey);
      debugPrint("pagekey :$pageKey");
      final isLastPage = newProducts.length < limit;

      if (isLastPage) {
        _pagingController.appendLastPage(newProducts);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newProducts, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Infinite Scroll Pagination"),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _pagingController.refresh(),
        child: PagedListView<int, Product>.separated(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate(
            itemBuilder: (context, product, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(id: product.id!),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: Image.network(
                          product.thumbnail!,
                          fit: BoxFit.cover,
                        ).image,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ListTile(
                            title: Text(product.title!),
                            subtitle: Text(product.description!),
                            trailing: Text("\$${product.brand!}")),
                      ),
                    ],
                  ),
                ),
              );
            },
            noMoreItemsIndicatorBuilder: (context) => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'No more products!',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            firstPageErrorIndicatorBuilder: (context) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 50,
                  horizontal: 30,
                ),
                child: Column(
                  children: [
                    const Text(
                      'Something went wrong',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${_pagingController.error}',
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () => _pagingController.refresh(),
                      child: const Text(
                        'Try Again!',
                        style: TextStyle(fontSize: 20),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
          separatorBuilder: (context, index) {
            return const Divider();
          },
        ),
      ),
    );
  }
}
